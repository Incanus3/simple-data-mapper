require_relative './utils'

# TODO: add mappers
# TODO: add validations

module SimpleDM
  class Backend
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


  class Relation
    class << self
      def inherited(relation_class)
        relation_class.const_set('Dataset', Class.new(Dataset))
      end

      def dataset_class
        const_get('Dataset')
      end

      def schema(&block)
        builder = Internal::SchemaBuilder.new

        builder.instance_eval(&block)
      end
    end

    def initialize(repository, registered_name)
      @repository      = repository
      @registered_name = registered_name
    end

    def create(**attributes)
      repository.store(registered_name, attributes)

      attributes
    end

    def all
      create_dataset(repository.fetch_all(registered_name))
    end

    def where(**filters)
      create_dataset(repository.fetch_filtered(registered_name, **filters))
    end

    private

    attr_reader :repository, :registered_name

    def create_dataset(records)
      self.class.dataset_class.new(records)
    end
  end


  class Dataset
    def initialize(records)
      @records = records
    end

    def to_a
      @records
    end
  end


  module Internal
    class SchemaBuilder
      def primary_key(column_name)
      end

      def string(column_name, max_length: nil, unique: false)
      end
    end
  end
end

SDM = SimpleDM
