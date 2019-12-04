require 'simple_dm'

class TestRepo < SDM::Repository
  Types = SDM::Types

  class Users < SDM::Relation
    schema do
      primary_key

      attribute :email, Types::Strict::String.constrained(
        max_size: 64,
        format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      )

      attribute  :username,   Types::Strict::String.constrained(max_size: 32)
      attribute? :first_name, Types::Strict::String.constrained(max_size: 32).optional
      attribute? :last_name,  Types::Strict::String.constrained(max_size: 32).optional
    end
  end

  register_relation Users
  register_backend  SDM::Backends::InMemoryBackend
end
