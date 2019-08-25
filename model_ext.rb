# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/actor'

module Plugin::WebFinger
  class Actor
    def outbox
      @outbox ||= fetch_collection outbox_url
    end
  end
end
