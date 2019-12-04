require 'dry/core/class_attributes'

require_relative './query'
require_relative './entity'
require_relative './dataset'
require_relative './mappers'
require_relative './exceptions'

module SimpleDM
  class Relation
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

    extend Dry::Core::ClassAttributes

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
end
