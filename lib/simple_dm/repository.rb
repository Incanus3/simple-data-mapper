require_relative './utils'
require_relative './relation'

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


  class Repository
    class << self
      attr_reader :relations

      def inherited(repository_class)
        repository_class.instance_variable_set(:@relations, {})
        repository_class.instance_variable_set(:@backends,  {})
      end

      def register_relation(relation_class, as: nil)
        as ||= Utils.snake_case(Utils.class_name(relation_class))

        define_method(as) do
          relation_class.new(data_provider, as)
        end

        relations[as] = relation_class
      end

      def register_backend(backend_class, as: backend_class.default_registered_name)
        backends[as] = backend_class

        define_singleton_method(as) do |*args, **kwargs|
          backend = if args.empty? && kwargs.empty?
                    then backend_class.new
                    else backend_class.new(*args, **kwargs)
                    end

          new(backend)
        end
      end

      attr_reader :backends
    end

    def initialize(backend)
      @data_provider = Internal::DataProvider.new(backend)
    end

    def relations
      self.class.relations
    end

    private

    attr_reader :data_provider
  end


  module Internal
    class DataProvider
      extend Forwardable

      def_delegators :@backend, :store, :fetch

      def initialize(backend)
        @backend = backend
      end
    end
  end
end

SDM = SimpleDM
