require 'spec_helper'
require 'test_repo'

RSpec.describe do
  let(:repo)     { TestRepo.in_memory     }
  let(:relation) { repo.users.as(:entity) }

  let!(:tomas ) { relation.create(username: 'tomas',  email: 'tomas@test.cz')  }
  let!(:prokop) { relation.create(username: 'prokop', email: 'prokop@test.cz') }

  it 'create returns record' do
    expect(tomas ).to be_a TestRepo::Users::Entity
    expect(prokop).to be_a TestRepo::Users::Entity

    expect(tomas.first_name).to eq nil
    expect(tomas.last_name ).to eq nil
    expect(tomas.username  ).to eq 'tomas'
    expect(tomas.email     ).to eq 'tomas@test.cz'
  end

  it 'all returns dataset with all records' do
    users = relation.all

    expect(users     ).to be_a TestRepo::Users::Dataset
    expect(users.to_a).to all(be_a TestRepo::Users::Entity)
  end

  it 'where returns dataset with filtered records' do
    users = relation.where(first_name: 'Tomáš')

    expect(users     ).to be_a TestRepo::Users::Dataset
    expect(users.to_a).to all(be_a TestRepo::Users::Entity)
  end
end
