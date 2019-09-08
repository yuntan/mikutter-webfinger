# frozen_string_literal: true

require_relative 'fetch'
require_relative 'model_ext'

Plugin.create :webfinger do
  pw = Plugin::WebFinger

  defmodelviewer pw::Actor do |actor|
    [
      ['acct', actor.acct],
      [_('名前'), actor.name],
      [_('投稿数'), actor.outbox.count],
      [_('フォロー数'), actor.following.count],
      [_('フォロワー数'), actor.followers.count],
    ]
  end

  deffragment pw::Actor, :summary, _('説明') do |actor|
    set_icon actor.icon
    nativewidget Gtk::VBox.new.closeup(Gtk::Label.new.tap do |label|
      label.text = actor.summary
      label.wrap = true
      label.selectable = true
    end)
  end

  deffragment pw::Actor, :outbox, _('投稿') do |actor|
    set_icon Skin[:timeline]

    outbox = actor.outbox
    Deferred.next do
      +outbox.fetch_page_next

      unless outbox.items
        nativewidget Gtk::Label.new Plugin[:webfinger]._ '取得出来ません'
        next
      end

      (timeline nil do
        order { |object| object.modified.to_i }
      end) << outbox.items.map(&:object)
    end.trap do |e|
      error e.full_message
    end
  end

  deffragment pw::Actor, :following, (_ 'フォロー') do |actor|
    set_icon Skin[:followings]

    following = actor.following
    Deferred.next do
      +following.fetch_page_next

      unless following.items
        nativewidget Gtk::Label.new Plugin[:webfinger]._ '取得出来ません'
        next
      end

      (timeline nil) << following.items
    end.trap do |e|
      error e.full_message
    end
  end

  deffragment pw::Actor, :followers, (_ 'フォロワー') do |actor|
    set_icon Skin[:followers]

    followers = actor.followers
    Deferred.next do
      +followers.fetch_page_next

      unless followers.items
        nativewidget Gtk::Label.new Plugin[:webfinger]._ '取得出来ません'
        next
      end

      (timeline nil) << followers.items
    end.trap do |e|
      error e.full_message
    end
  end
end
