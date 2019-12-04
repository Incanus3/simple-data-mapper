require_relative 'repository'

module SimpleDM
  class Backend
    @default_registered_name = nil

    class << self
      def default_registered_name
        @default_registered_name or raise 'default registered name not provided'
      end

      private

      attr_writer :default_registered_name
    end

    def store(_group_name, _attributes)
      raise NotImplementedError
    end

    def fetch(_group_name, _query)
      raise NotImplementedError
    end
  end

  module Backends
    class InMemoryBackend < SimpleDM::Backend
      self.default_registered_name = :in_memory

      def initialize
        @data = Hash.new { |hash, key| hash[key] = [] }
      end

      def store(group_name, attributes)
        data[group_name] << attributes
      end

      # TODO: apply query.limit
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
