module SimpleDM
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
