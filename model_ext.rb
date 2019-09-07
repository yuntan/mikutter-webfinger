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
      @actor ||= (Actor.find actor_uri or PW.fetch actor_uri)
    end

    def object
      @object ||= (Object.find object_uri or PW.fetch object_uri)
      # @object ||= (Object.find object_uri)
    end
  end

  class Actor
    include BasisModel
    include Identity

    def outbox
      @outbox ||= (Collection.find outbox_uri or PW.fetch outbox_uri)
    end

    def following
      @following ||= (Collection.find following_uri or PW.fetch following_uri)
    end

    def followers
      @followers ||= (Collection.find followers_uri or PW.fetch followers_uri)
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
          # Activity.find uri or Actor.find uri or Object.find uri or PW.fetch uri
          # Base.find uri
        else
          ModelBuilder.new(item).build
        end
      end
    end
  end

  class Object
    include BasisModel
    include Identity

    def attributed_to
      (uri = attributed_to_uri) or return nil
      @attributed_to ||= (Actor.find uri or PW.fetch uri)
      # @attributed_to ||= (Actor.find uri)
    end
  end
end
