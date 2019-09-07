# frozen_string_literal: true

module Plugin::WebFinger
  class Collection < Diva::Model
    field.int :count
    field.uri :page_first_uri

    def to_s
      "WebFinger #{type} (#{id}, count: #{count})"
    end
  end
end
