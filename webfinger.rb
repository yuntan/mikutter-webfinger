# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model/command'
require_relative 'model/actor'
require_relative 'model_ext'

PW = Plugin::WebFinger

Plugin.create :webfinger do
  intent PW::Command, label: _('WebFingerで開く') do |token|
    actor = discover token.model.query
    Plugin.call :open, actor
  end

  filter_quickstep_query do |query, yielder|
    query =~ RE_ACCT and yielder << PW::Command.new(query: query)
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
    tl = timeline nil
    actor.outbox.orderd_items.each do |activity|
      activity.type =~ /^Create$/ or next
      tl << activity.object
    end
  end
end
