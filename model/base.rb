# frozen_string_literal: true

module Plugin::WebFinger
  class Base < Diva::Model
    field.string :type, required: true
    field.uri    :id, required: true
    field.string :name, required: true
    field.uri    :url

    # for basis model
    # https://reference.mikutter.hachune.net/model/2017/05/06/basis-model.html
    alias title name
    alias uri id
    alias perma_link url

    # def initialize(*_)
    #   super
    #   Base.storage[uri] = self
    # end

    # def self.find(uri)
    #   @@storage[uri]
    # end
    #
    # def self.storage
    #   @@storage ||= {}
    # end
  end
end
