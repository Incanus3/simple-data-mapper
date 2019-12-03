require 'spec_helper'
require 'simple_dm'
require 'simple_dm/backends'

class TestRepo < SDM::Repository
  class Users < SDM::Relation
    schema do
      primary_key :id

      string :first_name, max_length: 32, unique: true
      string :last_name,  max_length: 32, unique: true
      string :username,   max_length: 32, unique: true
      string :email,      max_length: 64, unique: true
    end
  end

  register_relation Users
  register_backend  SDM::Backends::InMemoryBackend
end

RSpec.describe do # rubocop:disable Metrics/BlockLength
  context 'in memory backend' do
    let(:repo) { TestRepo.in_memory }

    let!(:tomas ) { repo.users.create(first_name: 'Tomáš',  last_name: 'Marný') }
    let!(:prokop) { repo.users.create(first_name: 'Prokop', last_name: 'Buben') }

    it 'create returns record' do
      expect(tomas[:first_name]).to eq 'Tomáš'
      expect(prokop[:last_name]).to eq 'Buben'
    end

    it 'all returns dataset with all records' do
      users = repo.users.all

      expect(users     ).to be_a TestRepo::Users::Dataset
      expect(users.to_a).to eq [tomas, prokop]
    end

    it 'where returns dataset with filtered records' do
      users = repo.users.where(first_name: 'Tomáš')

      expect(users     ).to be_a TestRepo::Users::Dataset
      expect(users.to_a).to eq [tomas]
    end
  end

  context 'postgres backend' do
    it 'works' do
      TestRepo.register_backend(SDM::Backends::PostgreSQLBackend)

      repo = TestRepo.postgres(host: 'localhost', database: 'simple_dm',
                               user: 'jakub',     password: 'jakub')

      users = repo.users

      expect { users.all }.to raise_exception NotImplementedError
    end
  end
end
