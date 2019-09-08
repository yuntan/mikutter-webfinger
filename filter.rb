# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/command'

Plugin.create :webfinger do
  pw = Plugin::WebFinger

  filter_quickstep_query do |query, yielder|
    query =~ pw::RE_ACCT and yielder << (pw::Command.new query: query)
    [query, yielder]
  end
end
