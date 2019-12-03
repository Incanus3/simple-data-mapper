require_relative './utils'
require_relative './relation'

# TODO: add mappers
# TODO: add validations

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

    def store(_relation_name, _attributes)
      raise NotImplementedError
    end

    def fetch_all(_relation_name)
      raise NotImplementedError
    end

    def fetch_filtered(_relation_name, **_filters)
      raise NotImplementedError
    end
  end


  class Repository
    extend Forwardable

    class << self
      attr_reader :relations

      def inherited(repository_class)
        repository_class.instance_variable_set(:@relations, {})
        repository_class.instance_variable_set(:@backends,  {})
      end

      def register_relation(relation_class, as: nil)
        as ||= Utils.snake_case(Utils.class_name(relation_class))

        define_method(as) do
          relation_class.new(self, as)
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

    def_delegators :@backend, :store, :fetch_all, :fetch_filtered

    def initialize(backend)
      @backend = backend
    end

    def relations
      self.class.relations
    end

    private

    attr_reader :backend
  end
end

SDM = SimpleDM
