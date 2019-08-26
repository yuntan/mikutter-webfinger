# frozen_string_literal: true

require_relative 'base'

module Plugin::WebFinger
  class Activity < Base
    field.uri :actor_uri
    field.uri :object_uri
  end
end
