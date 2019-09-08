# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/command'

Plugin.create :webfinger do
  pw = Plugin::WebFinger

  intent pw::Command, label: _('WebFingerで検索') do |token|
    Deferred.next do
      uri = +(pw.uri_from_acct token.model.query)
      actor = +(pw.fetch uri)
      [actor.outbox_uri, actor.following_uri, actor.followers_uri].each do |uri|
        +(pw.fetch uri)
      end
      Plugin.call :open, actor
    end.trap do |e|
      error e.full_message
    end
  end
end
