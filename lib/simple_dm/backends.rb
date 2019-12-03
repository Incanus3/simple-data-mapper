require_relative 'repository'

module SimpleDM
  module Backends
    class InMemoryBackend < SimpleDM::Backend
      self.default_registered_name = :in_memory

      def initialize
        @data = Hash.new { |hash, key| hash[key] = [] }
      end

      def store(relation_name, attributes)
        data[relation_name] << attributes
      end

      def fetch_all(relation_name)
        data[relation_name]
      end

      def fetch_filtered(relation_name, **filters)
        fetch_all(relation_name)
          .filter { |record| filters.all? { |attr, value| record[attr] == value } }
      end

      private

      attr_reader :data
    end

    class PostgreSQLBackend < SimpleDM::Backend
      self.default_registered_name = :postgres

      def initialize(**_kwargs)
        @connection = nil
      end
    end
  end
end
