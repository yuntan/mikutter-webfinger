# frozen_string_literal: true

require_relative 'base'

module Plugin::WebFinger
  class Object < Base
    include Diva::Model::MessageMixin

    register :webfinger_object, name: 'WebFinger Object', timeline: true

    field.string :content
    field.time   :created
    field.time   :modified
    field.uri    :attributed_to_uri

    # should be implemented for message model
    def user
      attributed_to
    end

    # should be implemented for message model
    def description
      content # TODO: deHTMLnize
    end

    def to_s
      "WebFinger #{type}"
    end
  end
end
