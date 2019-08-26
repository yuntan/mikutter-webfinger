# frozen_string_literal: true

require_relative 'fetch'
require_relative 'identity'
require_relative 'modelbuilder'
require_relative 'model/activity'
require_relative 'model/actor'
require_relative 'model/collection'
require_relative 'model/object'

module Plugin::WebFinger
  class Base
    include Identity
  end

  class Activity
    def actor
      @actor ||= (Base.find actor_uri or PW.fetch actor_uri)
    end

    def object
      @object ||= (Base.find object_uri or PW.fetch object_uri)
    end
  end

  class Actor
    def outbox
      @outbox ||= (Base.find outbox_uri or PW.fetch outbox_uri)
    end

    def following
      @following ||= (Base.find following_uri or PW.fetch following_uri)
    end

    def followers
      @followers ||= (Base.find followers_uri or PW.fetch followers_uri)
    end
  end

  class Collection
    attr_reader :items

    def page_next_uri
      @page_next_uri ||= page_first_uri
    end

    def fetch_page_next
      notice "fetch_page_next: next: #{page_next_uri}"

      data = JSON.parse \
        page_next_uri.read 'Accept' => 'application/activity+json'
      # data['type'] == 'OrderedCollectionPage' or return nil

      @page_next_uri = URI.parse data['next']
      @items ||= []
      @items += data['orderedItems'].map do |item|
        item or next
        if item.is_a? String
          uri = URI.parse item
          Base.find uri or PW.fetch uri
        else
          ModelBuilder.new(item).build
        end
      end
    end
  end

  class Object
    def attributed_to
      uri = attributed_to_uri
      @attributed_to ||= (Base.find uri or PW.fetch uri)
    end
  end
end
