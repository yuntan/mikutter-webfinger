# frozen_string_literal: true

require 'open-uri'
require 'rexml/document'

require_relative 'as2_types'

RE_TYPE_ACTIVITY = /^(Create|Announce)$/.freeze
RE_TYPE_ACTOR = /^Person$/.freeze # TODO
RE_TYPE_COLLECTION = /^(Ordered)?Collection$/.freeze
RE_TYPE_OBJECT = /^(Note|Article)$/.freeze

PW = Plugin::WebFinger

def fetch(uri)
  notice "fetch(#{uri})"

  data = begin
           # Activity Streams 2.0 object
           # https://www.w3.org/TR/activitystreams-vocabulary/
           JSON.parse uri.read 'Accept' => 'application/activity+json'
         rescue JSON::ParserError
           return nil
         end

end

def build(data)
  case data['type']
  when RE_TYPE_ACTOR
    PW::Actor.new data
  when RE_TYPE_OBJECT
    PW::Object.new data
  end
end

def fetch_collection(uri)
  notice "fetch_collection(#{uri})"

  data = JSON.parse uri.read 'Accept' => 'application/activity+json'
  data['type'] == 'OrderedCollection' or return nil

  c = PW::OrderedCollection.new(
    type: data['type'],
    total_items: data['totalItems'],
  )

  uri = URI.parse data['first']
  data = JSON.parse uri.read 'Accept' => 'application/activity+json'
  data['type'] == 'OrderedCollectionPage' or return nil

  # TODO: preserve `outbox['next']` for "load_more"
  c.orderd_items = data['orderedItems'].map do |item|
    options = get_options item
    options[:object] ||= (options[:object_url] and fetch options[:object_url])
    PW::Activity.new options
  end

  c
end

# def get_options(data)
#   id = data['id']
#
#   options = {
#     type: data['type'],
#     id: id ? URI.parse(id) : nil,
#   }
#
#   case options[:type]
#   when RE_TYPE_ACTOR
#     options.merge(
#       name: data['name'],
#       url: URI.parse(data['url']),
#       username: data['preferredUsername'],
#       summary: data['summary'], # FIXME: dehtmlize
#       icon_url: URI.parse(data['icon']['url']),
#       outbox_url: URI.parse(data['outbox']),
#       following_url: URI.parse(data['following']),
#       followers_url: URI.parse(data['followers']),
#     )
#   when RE_TYPE_OBJECT
#     attributed_to = data['attributed_to']
#     attributed_to.is_a?(String) || attributed_to.nil? \
#       or PW::Actor.new attributed_to
#     options.merge(
#       name: data['name'],
#       url: URI.parse(data['url']),
#       attributed_to_url: (attributed_to.is_a? String \
#                           and URI.parse attributed_to),
#       created: data['created'], # FIXME: Date.parse
#       content: data['content'],
#     )
#   when RE_TYPE_ACTIVITY
#     actor = data['actor']
#     object = data['object']
#     options.merge(
#       actor: (actor.is_a?(String) || actor.nil? \
#               or PW::Actor.new get_options actor),
#       actor_url: (actor.is_a? String and URI.parse actor),
#       object: (object.is_a?(String) || object.nil? \
#                or PW::Object.new get_options object),
#       object_url: (object.is_a? String and URI.parse object),
#     )
#   else
#     notice "unknown type '#{options[:type]}'"
#     options
#   end
# end

def get_options(data)
  case data['type']
  when RE_TYPE_ACTIVITY
    actor = data['actor']
    object = data['object']

    actor.is_a?(String) || actor.nil? or build get_options actor
    object.is_a?(String) || object.nil? or build get_options object

    data.merge(
      actor_url: (actor.is_a? String and actor or actor&.get 'id'),
      object_url: (object.is_a? String and object or object&.get 'id'),
    )

  when RE_TYPE_ACTOR
    data.merge(
      username: data['preferredUsername'],
      icon_url: URI.parse(data['icon']['url']),
      outbox_url: URI.parse(data['outbox']),
      following_url: URI.parse(data['following']),
      followers_url: URI.parse(data['followers']),
    )

  when RE_TYPE_OBJECT
    attributed_to = data['attributed_to']
    attributed_to.is_a?(String) || attributed_to.nil? \
      or PW::Actor.new attributed_to
    options.merge(
      name: data['name'],
      url: URI.parse(data['url']),
      attributed_to_url: (attributed_to.is_a? String \
                          and URI.parse attributed_to),
      created: data['created'], # FIXME: Date.parse
      content: data['content'],
    )

  else
    notice "unknown type '#{options[:type]}'"
    options
  end
end

def discover(query)
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
  link = data['links'].find { |link| link['rel'] == 'self' }

  uri = URI.parse link['href']
  # data = JSON.parse uri.read 'Accept' => 'application/activity+json'
  # data['type'] == 'Person' or return nil

  # Actor.new(
  #   acct: acct,
  #   name: data['name'],
  #   username: data['preferredUsername'],
  #   summary: data['summary'],
  #   uri: URI.parse(data['url']),
  #   icon_uri: URI.parse(data['icon']['url']),
  #   outbox_uri: URI.parse(data['outbox']),
  #   # following_uri: URI.parse(data['following']),
  #   # followers_uri: URI.parse(data['followers']),
  # )

  fetch uri, acct: acct
end
