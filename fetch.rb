# frozen_string_literal: true

require 'open-uri'
require 'rexml/document'

require_relative 'modelbuilder'

module Plugin::WebFinger
  def fetch(uri)
    notice "fetch(#{uri})"

    data =
      begin
        # Activity Streams 2.0 object
        # https://www.w3.org/TR/activitystreams-vocabulary/
        JSON.parse uri.read 'Accept' => 'application/activity+json'
      rescue JSON::ParserError
        return nil
      end

    ModelBuilder.new(data).build
  end

  def discover(query)
    notice "discover(#{query})"

    (m = RE_ACCT.match query || RE_PROFILE_URI.match(query)) or return nil

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

    uri = URI.parse link['href']

    fetch(uri).tap { |actor| actor.acct = acct }
  end

  module_function :fetch, :discover
end
