# frozen_string_literal: true

module Plugin::WebFinger
  Activity = Struct.new('Activity',
                        :type, :id, :actor, :actor_url, :object, :object_url)

  Collection = Struct.new 'Collection', :type, :id, :total_items, :items

  OrderedCollection = Struct.new('OrderedCollection',
                                 :type, :id, :total_items, :orderd_items)
end
