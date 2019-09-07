# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/command'

Plugin.create :webfinger do
  PW = Plugin::WebFinger

  filter_quickstep_query do |query, yielder|
    query =~ PW::RE_ACCT and yielder << (PW::Command.new query: query)
    [query, yielder]
  end
end
