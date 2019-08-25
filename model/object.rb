# frozen_string_literal: true

module Plugin::WebFinger
  class Object < Diva::Model
    include Diva::Model::MessageMixin

    register :webfinger_object, name: 'WebFinger Object', timeline: true

    field.string :type, required: true
    field.uri    :id, required: true
    field.string :name, required: true
    field.string :content
    field.time   :created
    field.uri    :attributed_to_url
    field.uri    :url

    # for basis model
    # https://reference.mikutter.hachune.net/model/2017/05/06/basis-model.html
    alias title name
    alias uri id
    alias perma_link url

    class << self
      @@objects = WeakStorage.new Diva::URI, Object, name: 'WebFinger Objects'

      def find(uri)
        @@objects[uri]
      end
    end

    def initialize(*args)
      super
      @@objects[uri] = self
    end

    # should be implemented for message model
    def user
      attributed_to || self.attributed_to = Enumerator.new do |y|
        Plugin.filtering :webfinger_object, attributed_to_url, y
      end.first
    end

    # should be implemented for message model
    def description
      content
    end

    def attributed_to
      Object.findbyid attributed_to_url
    end

    def to_s
      "WebFinger #{type}"
    end
  end
end
