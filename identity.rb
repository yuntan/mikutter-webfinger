# frozen_string_literal: true

module Plugin::WebFinger
  module Identity
    module ClassMethods
      def find(uri)
        obj = storage[uri]
        obj.is_a? self or return nil
        notice "using cached #{obj.class.name} for #{uri}"
        obj
      end

      def register(obj)
        (obj.is_a? self) && obj&.uri or return
        storage[obj.uri] = obj
      end

    private

      def storage
        # @@storage ||= WeakStorage.new Diva::URI, Diva::Model, name: 'WebFinger Objects'
        @@storage ||= {}
      end
    end

    def self.prepended(klass)
      klass.extend ClassMethods
    end

    def initialize(*args, &block)
      super
      self.class.register self
    end
  end
end
