require 'spec_helper'
require 'test_repo'

RSpec.describe do # rubocop:disable Metrics/BlockLength
  context 'in memory backend' do
    let(:repo) { TestRepo.in_memory }

    let!(:tomas ) { repo.users.create(username: 'tomas',  email: 'tomas@test.cz') }
    let!(:prokop) { repo.users.create(username: 'prokop', email: 'prokop@test.cz') }

    it 'create returns record' do
      expect(tomas[:username]).to eq 'tomas'
      expect(prokop[:email]).to eq 'prokop@test.cz'
    end

    it 'all returns dataset with all records' do
      users = repo.users.all

      expect(users     ).to be_a TestRepo::Users::Dataset
      expect(users.to_a).to eq [tomas, prokop]
    end

    it 'where returns dataset with filtered records' do
      users = repo.users.where(username: 'tomas')

      expect(users     ).to be_a TestRepo::Users::Dataset
      expect(users.to_a).to eq [tomas]
    end
  end

  context 'postgres backend' do
    it 'works' do
      TestRepo.register_backend(SDM::Backends::PostgreSQLBackend)

      repo = TestRepo.postgres(host: 'localhost', database: 'simple_dm',
                               user: 'jakub',     password: 'jakub')

      dataset = repo.users.all

      expect { dataset.to_a }.to raise_exception NotImplementedError
    end
  end
end
