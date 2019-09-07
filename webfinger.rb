# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/command'
require_relative 'model_ext'

module Plugin::WebFinger
  PW = Plugin::WebFinger
end

Plugin.create :webfinger do
  PW = Plugin::WebFinger

  intent PW::Command, label: _('WebFingerで開く') do |token|
    Deferred.next do
      uri = +(PW.uri_from_acct token.model.query)
      actor = +(PW.fetch uri)
      [actor.outbox_uri, actor.following_uri, actor.followers_uri].each do |uri|
        +(PW.fetch uri)
      end
      Plugin.call :open, actor
    end
  end

  filter_quickstep_query do |query, yielder|
    query =~ PW::RE_ACCT and yielder << (PW::Command.new query: query)
    [query, yielder]
  end

  defmodelviewer PW::Actor do |actor|
    [
      ['acct', actor.acct],
      [_('名前'), actor.name],
      [_('別名'), actor.username],
      # [_('投稿数'), actor.outbox.count],
      # [_('フォロー'), actor.following.count],
      # [_('フォロワー'), actor.followers.count],
    ]
  end

  deffragment PW::Actor, :summary, _('説明') do |actor|
    set_icon actor.icon
    nativewidget(Gtk::Label.new(actor.summary).tap do |label|
      label.selectable = true
    end)
  end

  deffragment PW::Actor, :outbox, _('投稿') do |actor|
    set_icon Skin[:timeline]
    tl = timeline nil do
      order { |object| object.modified.to_i }
    end

    Deferred.next do
      +actor.outbox.fetch_page_next
      actor.outbox.items.each do |activity|
        activity.object or +(PW.fetch activity.object_uri)
        obj = activity.object
        obj.attributed_to or +(PW.fetch obj.attributed_to_uri)
      end
      tl << actor.outbox.items
        .filter { |activity| activity.type == 'Create' }
        .map(&:object)
    end.trap do |err|
      error err.full_message
      warn err.backtrace.join("\n")
    end
  end
end
