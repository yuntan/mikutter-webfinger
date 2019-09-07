# frozen_string_literal: true

module Plugin::WebFinger
  module Identity
    module ClassMethods
      # override Diva::ModelExtend#find_by_uri
      # returns Diva::Model | Deferrable
      def find_by_uri(uri)
        find_by_uri! uri or PM.fetch uri # Deferreableを返す
      end

      # returns Diva::Model | nil
      def find_by_uri!(uri)
        uri = (uri.is_a? Diva::URI and uri or Diva::URI.new uri)
        obj = storage[uri.hash]
        obj.is_a? self or return nil
        notice "using cached #{obj}"
        obj
      end

      # override Diva::ModelExtend#store_datum
      def store_datum(model)
        notice "model: #{model}"

        type_strict model => self
        model.uri or return
        uri = model.uri
        uri = (uri.is_a? Diva::URI and uri or Diva::URI.new uri)
        storage[uri.hash] = model
      end

    private

      def storage
        @storage ||=
          WeakStorage.new Integer, Diva::Model, name: 'WebFinger Objects'
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
