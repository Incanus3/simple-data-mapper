require 'dry-struct'
require 'dry-types'

require_relative './utils'

module SimpleDM
  class ValidationError < RuntimeError
  end

  class Relation
    class << self
      def inherited(relation_class)
        # TODO: don't overwrite, raise if not Dataset subclass
        relation_class.const_set('Dataset', Class.new(Dataset))
      end

      def schema(&block)
        # builder = Internal::SchemaBuilder.new
        # builder.instance_eval(&block)

        # TODO: raise if both custom Entity defined and schema called
        const_set('Entity', Class.new(Entity, &block))
      end

      attr_reader :schema_block
    end

    def initialize(data_provider, registered_name, mapper_name = :identity)
      @data_provider   = data_provider
      @registered_name = registered_name
      @mapper_name     = mapper_name
      @mappers         = Mappers.new(self)
    end

    def as(mapper_name)
      self.class.new(data_provider, registered_name, mapper_name)
    end

    def create(**attributes)
      entity = mappers[:entity].call(attributes)

      validated_attributes = entity.to_h

      data_provider.store(registered_name, validated_attributes)

      mapper.call(validated_attributes)
    end

    def all
      create_dataset
    end

    def where(**filters)
      create_dataset(filters: filters)
    end

    def entity_class
      self.class.const_get('Entity')
    end

    private

    attr_reader :data_provider, :registered_name, :mapper_name, :mappers

    def dataset_class
      self.class.const_get('Dataset')
    end

    def create_dataset(**kwargs)
      dataset_class.new(data_provider, registered_name, mapper: mapper, **kwargs)
    end

    def mapper
      mappers[mapper_name]
    end
  end


  module Types
    include Dry.Types()
  end


  class Entity < Dry::Struct
  end


  class Dataset
    def initialize(data_provider, group_name, mapper:, **query_options)
      @data_provider = data_provider
      @group_name    = group_name
      @mapper        = mapper
      @query         = Query.new(**query_options)
    end

    def to_a
      data_provider.fetch(group_name, query).map(&mapper)
    end

    private

    attr_reader :data_provider, :group_name, :mapper, :query
  end


  class Query
    attr_reader :filters

    def initialize(filters: {})
      @filters = filters
    end
  end


  class Mappers
    include Transproc::Registry

    def initialize(relation)
      @relation = relation

      import :identity, from: Transproc::Coercions
    end

    def entity(attributes)
      relation.entity_class.new(**attributes)
    rescue Dry::Struct::Error => e
      raise ValidationError, e
    end

    private

    attr_reader :relation
  end


  # module Internal
  #   class SchemaBuilder
  #     def primary_key(column_name)
  #     end

  #     def string(column_name, max_length: nil, unique: false)
  #     end
  #   end
  # end
end
