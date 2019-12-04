require_relative './exceptions'

module SimpleDM
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
