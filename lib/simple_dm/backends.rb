require_relative 'repository'

module SimpleDM
  module Backends
    class InMemoryBackend < SimpleDM::Backend
      self.default_registered_name = :in_memory

      def initialize
        @data = Hash.new { |hash, key| hash[key] = [] }
      end

      def store(group_name, attributes)
        data[group_name] << attributes
      end

      def fetch(group_name, query)
        if query.filters.empty?
          fetch_all(group_name)
        else
          fetch_filtered(group_name, query.filters)
        end
      end

      private

      def fetch_all(group_name)
        data[group_name]
      end

      def fetch_filtered(group_name, filters)
        fetch_all(group_name)
          .filter { |record| filters.all? { |attr, value| record[attr] == value } }
      end

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
