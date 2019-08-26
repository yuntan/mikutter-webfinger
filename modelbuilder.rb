# frozen_string_literal: true

RE_TYPE_ACTIVITY = /^(Create|Announce)$/.freeze
RE_TYPE_ACTOR = /^Person$/.freeze # TODO
RE_TYPE_COLLECTION = /^(Ordered)?Collection$/.freeze
RE_TYPE_OBJECT = /^(Note|Article)$/.freeze

module Plugin::WebFinger
  class ModelBuilder
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def build
      klass.new options
    end

    def klass
      @klass ||=
        case @data['type']
        when RE_TYPE_ACTIVITY then Activity
        when RE_TYPE_ACTOR then Actor
        when RE_TYPE_COLLECTION then Collection
        when RE_TYPE_OBJECT then Object
        end
    end

    def options
      @options and return @options

      opts = {
        type: data['type'],
        id: data['id'],
      }

      @options =
        if klass == Activity
          actor = data['actor']
          object = data['object']

          actor.is_a? Hash and ModelBuilder.new(actor).build
          object.is_a? Hash and ModelBuilder.new(object).build

          opts.merge(
            actor_uri: (actor.is_a? String and actor or actor&.fetch 'id'),
            object_uri: (object.is_a? String and object or object&.fetch 'id'),
          )

        elsif klass == Actor
          opts.merge(
            name: data['name'],
            username: data['preferredUsername'],
            summary: data['summary'], # FIXME: dehtmlize
            url: data['url'],
            icon_url: data['icon']['url'],
            outbox_uri: data['outbox'],
            following_uri: data['following'],
            followers_uri: data['followers'],
          )

        elsif klass == Collection
          opts.merge(
            count: data['totalItems'],
            page_first_uri: data['first'],
          )

        elsif klass == Object
          attributed_to = data['attributed_to']

          attributed_to.is_a? Hash and ModelBuilder.new(attributed_to).build

          opts.merge(
            name: data['name'],
            url: data['url'],
            attributed_to_uri: (attributed_to.is_a? String and attributed_to \
                                or attributed_to&.fetch 'id'),
            created: data['created'], # FIXME: parse
            content: data['content'],
          )

        else
          notice "unknown type '#{opts[:type]}'"
          opts
        end
    end
  end
end
