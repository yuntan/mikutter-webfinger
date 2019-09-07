# frozen_string_literal: true

module Plugin::WebFinger
  class Collection < Diva::Model
    field.int :count
    field.uri :page_first_uri
  end
end
