# frozen_string_literal: true

require_relative 'base'

module Plugin::WebFinger
  class Collection < Base
    field.int :count
    field.uri :page_first_uri
  end
end
