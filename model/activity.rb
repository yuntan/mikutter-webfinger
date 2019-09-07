# frozen_string_literal: true

module Plugin::WebFinger
  class Activity < Diva::Model
    field.uri :actor_uri
    field.uri :object_uri

    def to_s
      "WebFinger #{type} (#{id})"
    end
  end
end
