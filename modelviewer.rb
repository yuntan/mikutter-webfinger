# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model_ext'

Plugin.create :webfinger do
  PW = Plugin::WebFinger

  defmodelviewer PW::Actor do |actor|
    [
      ['acct', actor.acct],
      [_('名前'), actor.name],
      [_('投稿数'), actor.outbox.count],
      [_('フォロー'), actor.following.count],
      [_('フォロワー'), actor.followers.count],
    ]
  end

  deffragment PW::Actor, :summary, _('説明') do |actor|
    set_icon actor.icon
    nativewidget Gtk::VBox.new.closeup(Gtk::Label.new.tap do |label|
      label.text = actor.summary
      label.wrap = true
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
