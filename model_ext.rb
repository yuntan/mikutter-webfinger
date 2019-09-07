# frozen_string_literal: true

require_relative 'fetch'
require_relative 'modelbuilder'
require_relative 'mixin/basismodel'
require_relative 'mixin/identity'
require_relative 'model/activity'
require_relative 'model/actor'
require_relative 'model/collection'
require_relative 'model/object'

module Plugin::WebFinger
  class Activity
    include BasisModel
    include Identity

    def actor
      @actor ||= Actor.find_by_uri actor_uri
    end

    def object
      @object ||= Object.find_by_uri object_uri
    end
  end

  class Actor
    include BasisModel
    include Identity

    def outbox
      @outbox ||= Collection.find_by_uri outbox_uri
    end

    def following
      @following ||= Collection.find_by_uri following_uri
    end

    def followers
      @followers ||= Collection.find_by_uri followers_uri
    end
  end

  class Collection
    include BasisModel
    include Identity

    attr_reader :items

    def page_next_uri
      @page_next_uri ||= page_first_uri
    end

    def fetch_page_next
      Deferred.new do
        notice "page_next_uri: #{page_next_uri}"

        data = JSON.parse \
          page_next_uri.read 'Accept' => 'application/activity+json'
        data['type'] == 'OrderedCollectionPage' \
          or next Deferred.fail 'invalid type'
        data
      end.next do |data|
        @page_next_uri = URI.parse data['next']
        @items ||= []
        @items += data['orderedItems'].map do |item|
          item or next
          if item.is_a? String
            uri = URI.parse item
            (Activity.find_by_uri uri) \
              || (Actor.find_by_uri uri) \
              || (Object.find_by_uri uri) \
              || +(PW.fetch uri)
          else
            ModelBuilder.new(item).build
          end
        end
      end
    end
  end

  class Object
    include BasisModel
    include Identity

    def attributed_to
      @attributed_to ||= Actor.find_by_uri attributed_to_uri
    end
  end
end
