require 'dry-types'
require 'dry-struct'

module SimpleDM
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
end
