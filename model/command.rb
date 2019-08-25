# frozen_string_literal: true
require_relative 'actor'
require_relative 'object'

module Plugin::WebFinger
  class Command < Diva::Model
    register :webfinger_command, name: Plugin[:webfinger]._('WebFingerコマンド')

    field.string :query, required: true

    def title
      Plugin[:webfinger]._('%sをWebFingerで開く') % query
    end

    # def slug
    #   :webfinger
    # end
  end
end
