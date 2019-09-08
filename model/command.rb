# frozen_string_literal: true

module Plugin::WebFinger
  class Command < Diva::Model
    register :webfinger_command, name: Plugin[:webfinger]._('WebFingerコマンド')

    field.string :query, required: true

    def title
      format (Plugin[:webfinger]._ '%{query}をWebFingerで検索'), query: query
    end
  end
end
