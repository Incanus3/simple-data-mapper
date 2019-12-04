require 'spec_helper'
require 'test_repo'

class DefaultMappersTestRepo < TestRepo
  class UsersWithDefaultMappers < Users
    default_mappers [:entity]
  end

  register_relation UsersWithDefaultMappers, as: :users
end

RSpec.describe do # rubocop:disable Metrics/BlockLength
  shared_examples 'examples' do
    let!(:tomas ) { relation.create(username: 'tomas',  email: 'tomas@test.cz')  }
    let!(:prokop) { relation.create(username: 'prokop', email: 'prokop@test.cz') }

    it 'create returns record' do
      expect(tomas ).to be_a TestRepo::Users::Entity
      expect(prokop).to be_a TestRepo::Users::Entity

      expect(tomas.id        ).to be_a Integer
      expect(tomas.first_name).to eq nil
      expect(tomas.last_name ).to eq nil
      expect(tomas.username  ).to eq 'tomas'
      expect(tomas.email     ).to eq 'tomas@test.cz'
    end

    it 'all returns dataset with all records' do
      users = relation.all

      expect(users.to_a).to all(be_a TestRepo::Users::Entity)
    end

    it 'where returns dataset with filtered records' do
      users = relation.where(first_name: 'Tomáš')

      expect(users.to_a).to all(be_a TestRepo::Users::Entity)
    end
  end

  context 'with explicit mappers' do
    let(:relation) { TestRepo.in_memory.users.as(:entity) }

    include_examples 'examples'
  end

  context 'with default mappers' do
    let(:relation) { DefaultMappersTestRepo.in_memory.users }

    include_examples 'examples'
  end
end
