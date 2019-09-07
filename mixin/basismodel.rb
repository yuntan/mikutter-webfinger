# frozen_string_literal: true

module Plugin::WebFinger
  module BasisModel
    def self.included(klass)
      klass.field.string :type, required: true
      klass.field.uri    :id,   required: true
      klass.field.string :name, required: true
      klass.field.uri    :url
    end

    # for basis model
    # https://reference.mikutter.hachune.net/model/2017/05/06/basis-model.html
    def title
      name
    end

    def uri
      id
    end

    def perma_link
      url
    end
  end
end
