# frozen_string_literal: true

module Plugin::WebFinger
  module Identity
    module IdentityExtend
      def find(uri)
        storage[uri]
      end

      # def register(obj)
      #   storage[obj.uri] = obj
      # end

      def register
        storage[uri] = self
      end

    private

      def storage
        @storage ||= WeakStorage.new Diva::URI, Diva::Model, name: 'WebFinger Objects'
      end
    end

    def self.included(klass)
      klass.extend IdentityExtend
    end

    def initialize(*args, &block)
      super
      # self.class.register self
      self.class.register
    end
  end
end
