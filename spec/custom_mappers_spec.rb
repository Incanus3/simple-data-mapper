require 'spec_helper'
require 'test_repo'
require 'transproc/hash'

class CustomMappersTestRepo < TestRepo
  class UsersWithCustomMappers < Users
    class Mappers < SDM::Mappers
      def import_mappers
        import :stringify_keys, from: Transproc::HashTransformations
      end

      def upcase_username(entity)
        entity.new(username: entity.username.upcase)
      end
    end
  end

  register_relation UsersWithCustomMappers, as: :users
end

RSpec.describe do
  let(:relation) { CustomMappersTestRepo.in_memory.users }

  it 'works with custom matchers' do
    created_tomas = relation
      .create(username: 'tomas', email: 'tomas@test.cz')
    created_lukas = relation.with_mappers(:stringify_keys)
      .create(username: 'lukas', email: 'lukas@test.cz')

    fetched_tomas = relation.with_mappers(:stringify_keys).first
    fetched_lukas = relation.last

    expect(created_tomas[:username] ).to eq 'tomas'
    expect(created_lukas['username']).to eq 'lukas'

    expect(fetched_tomas['username']).to eq 'tomas'
    expect(fetched_lukas[:username] ).to eq 'lukas'
  end

  it 'works with composite mappers' do
    created_tomas = relation.as(:entity)
      .create(username: 'tomas', email: 'tomas@test.cz')
    created_lukas = relation.as(:entity, :upcase_username)
      .create(username: 'lukas', email: 'lukas@test.cz')

    fetched_tomas = relation.as(:entity, :upcase_username).first
    fetched_lukas = relation.as(:entity).last

    expect(created_tomas.username).to eq 'tomas'
    expect(created_lukas.username).to eq 'LUKAS'

    expect(fetched_tomas.username).to eq 'TOMAS'
    expect(fetched_lukas.username).to eq 'lukas'
  end
end
