# frozen_string_literal: true

require 'open-uri'
require 'rexml/document'

require_relative 'modelbuilder'

module Plugin::WebFinger
  RE_ACCT = /^@?(?<name>[a-z0-9\-_]+)@(?<domain>[a-z0-9\-]+(\.[a-z0-9\-]+)+)$/.freeze

module_function

  def fetch(uri)
    Deferred.new do
      uri or raise ArgumentError, 'uri is nil'

      notice "fetch uri: #{uri}"

      data =
        begin
          # Activity Streams 2.0 object
          # https://www.w3.org/TR/activitystreams-vocabulary/
          JSON.parse uri.read 'Accept' => 'application/activity+json'
        rescue JSON::ParserError => e
          error e.full_message
          raise e
        end

      ModelBuilder.new(data).build
    end
  end

  def uri_from_acct(acct)
    Deferred.new do
      notice "uri_from_acct acct: #{acct}"

      (m = RE_ACCT.match acct) \
        or raise ArgumentError, "invalid acct: #{acct}"
      acct = "#{m[:name]}@#{m[:domain]}"

      # RFC6415 Web Host Metadata
      uri = URI.parse "https://#{m[:domain]}/.well-known/host-meta"
      doc = REXML::Document.new uri.read 'Accept' => 'application/xrd+xml'
      template = REXML::XPath.match(doc, '/XRD/Link[@rel="lrdd"]') \
        .first.attribute('template').to_s

      # RFC7033 WebFinger
      uri = URI.parse template.sub(/\{uri\}/, "acct:#{acct}")
      data = JSON.parse uri.read 'Accept' => 'application/jrd+json'
      link = data['links'].find { |l| l['rel'] == 'self' }

      URI.parse link['href']
    end
  end
end
