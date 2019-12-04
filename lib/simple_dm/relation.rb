require 'dry/core/class_attributes'
require 'dry-struct'
require 'dry-types'

require_relative './utils'

module SimpleDM
  module Constants
    Undefined = Dry::Core::Constants::Undefined
  end


  class ValidationError < RuntimeError
  end


  class Relation
    extend Dry::Core::ClassAttributes

    class EntityClassAlreadyDefined < RuntimeError
      def initialize
        super('Entity class is already defined')
      end
    end

    class InvalidEntityClass < RuntimeError
      def initialize
        super('Entity class is not a subclass of SimpleDM::Entity')
      end
    end

    class InvalidMappersClass < RuntimeError
      def initialize
        super('Mappers class is not a subclass of SimpleDM::Mappers')
      end
    end

    defines :default_mappers

    default_mappers [:identity]

    class << self
      def inherited(relation_class)
        super(relation_class)

        relation_class.const_set('Dataset', Class.new(Dataset))
      end

      def schema(&block)
        raise EntityClassAlreadyDefined if const_defined?('Entity')

        const_set('Entity', Class.new(Entity, &block))
      end
    end

    def initialize(data_provider, registered_name, mapper_names = self.class.default_mappers)
      @data_provider   = data_provider
      @registered_name = registered_name
      @mapper_names    = mapper_names
      mappers          = mappers_class.new(self)
      @mapper          = mapper_names.map { |mapper_name| mappers[mapper_name] }.reduce(&:>>)
    end

    def with_mappers(*mapper_names)
      self.class.new(data_provider, registered_name, mapper_names)
    end

    alias as with_mappers

    def create(**attributes)
      validated_attributes = validate(attributes)

      data_provider.store(registered_name, validated_attributes)

      mapper.call(validated_attributes)
    end

    def all
      create_dataset
    end

    def first
      mapper.call(data_provider.fetch(registered_name, Query.new(limit: 1)).first)
    end

    def last
      mapper.call(data_provider.fetch(registered_name, Query.new(limit: 1)).last)
    end

    def where(**filters)
      create_dataset(filters: filters)
    end

    def entity_class
      return @__entity_class if @__entity_class

      eclass = self.class.const_get('Entity')

      raise InvalidEntityClass unless eclass < Entity

      @__entity_class = eclass
    end

    private

    attr_reader :data_provider, :registered_name, :mapper_names, :mapper

    def dataset_class
      self.class.const_get('Dataset')
    end

    def mappers_class
      return @__mappers_class if @__mappers_class

      mclass = self.class.const_defined?('Mappers') && self.class.const_get('Mappers') || Mappers

      raise InvalidMappersClass unless mclass <= Mappers

      @__mappers_class = mclass
    end

    def create_dataset(**kwargs)
      dataset_class.new(data_provider, registered_name, mapper: mapper, **kwargs)
    end

    def validate(attributes)
      entity_class.schema.apply(attributes)
    rescue Dry::Types::CoercionError => e
      raise ValidationError, e
    end
  end


  module Types
    include Dry.Types()
  end


  class Entity < Dry::Struct::Value
    schema schema.strict

    transform_keys(&:to_sym)

    def self.primary_key(name = :id)
      attribute(name, Types::Strict::Integer.default { Time.now.to_i }) # for now
    end
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
    attr_reader :filters, :limit

    def initialize(filters: {}, limit: nil)
      @filters = filters
      @limit   = limit
    end
  end


  class Mappers
    include Transproc::Registry

    def initialize(relation)
      @relation = relation

      import :identity, from: Transproc::Coercions

      import_mappers
    end

    def import_mappers
      # serves as a hook for subclasses
    end

    def entity(attributes)
      relation.entity_class.new(**attributes)
    rescue Dry::Struct::Error => e
      raise ValidationError, e
    end

    private

    attr_reader :relation
  end
end
