# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/command'

Plugin.create :webfinger do
  PW = Plugin::WebFinger

  intent PW::Command, label: _('WebFingerで検索') do |token|
    Deferred.next do
      uri = +(PW.uri_from_acct token.model.query)
      actor = +(PW.fetch uri)
      [actor.outbox_uri, actor.following_uri, actor.followers_uri].each do |uri|
        +(PW.fetch uri)
      end
      Plugin.call :open, actor
    end
  end
end
