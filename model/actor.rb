# frozen_string_literal: true

require_relative 'base'

RE_ACCT = /^@?(?<name>[a-z0-9\-_]+)@(?<domain>[a-z0-9\-]+(\.[a-z0-9\-]+)+)$/.freeze
RE_PROFILE_URI = %r{^https://(?<domain>[a-z0-9\-]+(\.[a-z0-9\-]+)+)/@(?<name>[a-z0-9\-_]+)$}.freeze

module Plugin::WebFinger
  class Actor < Base
    include Diva::Model::UserMixin

    register :webfinger_actor, name: 'WebFinger Actor'

    field.string :acct
    field.string :username
    field.string :summary
    field.uri    :icon_url
    field.uri    :outbox_uri
    field.uri    :following_uri
    field.uri    :followers_uri
    field.uri    :liked_uri

    handle RE_PROFILE_URI do |uri|
      m = RE_PROFILE_URI.match uri.to_s
      acct = "#{m[:name]}@#{m[:domain]}"
      discover acct
    end

    # should be implemented for user model
    def icon
      Enumerator.new do |y|
        Plugin.filtering :photo_filter, icon_url, y
      end.lazy.map do |photo|
        Plugin.filtering(:miracle_icon_filter, photo)[0]
      end.first
    end

    def description
      summary # TODO: deHTMLnize
    end

    def to_s
      "WebFinger #{type}(acct:#{acct})"
    end

    # Actor implements ActivityPub Actor object
    # https://www.w3.org/TR/activitypub/#actor-objects
    def outbox; end
    def following; end
    def followers; end
    def liked; end

  private

    def fetch_outbox
      data = JSON.parse outbox_uri.read 'Accept' => 'application/activity+json'
      data['type'] == 'OrderedCollection' or return nil

      uri = URI.parse data['first']
      data = JSON.parse uri.read 'Accept' => 'application/activity+json'
      data['type'] == 'OrderedCollectionPage' or return nil

      # outbox['next']
      data['orderedItems'].map do |item|
        object = item['object']
        Activity.new(
          type: item['type'],
          object: object.is_a?(String) ? fetch(object) : object,
        )
        assert item['object']['type'] == 'Note'
        item['object']['published']
        item['object']['url']
        item['object']['name'].nil?
        item['object']['content']
        item['object']['atttachment']
        item['object']['rep']

        assert item['object']['type'] == 'Article'
        item['object']['published']
        item['object']['url']
        item['object']['name']
        item['object']['content']

        item['type'] == 'Announce'
        item['published']
        URI.parse item['object']
      end
    end
  end
end
