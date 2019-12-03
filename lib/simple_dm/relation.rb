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

    def initialize(data_provider, registered_name)
      @data_provider   = data_provider
      @registered_name = registered_name
    end

    def create(**attributes)
      data_provider.store(registered_name, attributes)

      attributes
    end

    def all
      create_dataset
    end

    def where(**filters)
      create_dataset(filters: filters)
    end

    private

    attr_reader :data_provider, :registered_name

    def create_dataset(**kwargs)
      self.class.dataset_class.new(data_provider, registered_name, **kwargs)
    end
  end


  class Dataset
    def initialize(data_provider, group_name, **query_options)
      @data_provider = data_provider
      @group_name    = group_name
      @query         = Query.new(**query_options)
    end

    def to_a
      data_provider.fetch(group_name, query)
    end

    private

    attr_reader :data_provider, :group_name, :query
  end


  class Query
    attr_reader :filters

    def initialize(filters: {})
      @filters = filters
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
