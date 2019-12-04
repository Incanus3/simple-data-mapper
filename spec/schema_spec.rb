require 'spec_helper'
require 'test_repo'

RSpec.describe do # rubocop:disable Metrics/BlockLength
  let(:relation) { TestRepo.in_memory.users }

  it 'succeeds if all values are correctly provided' do
    expect do
      relation.create(first_name: 'Tomáš', last_name: 'Marný',
                      username: 'tomas', email: 'tomas@test.cz')
    end.not_to raise_exception
  end

  it "succeeds if optional attributes aren't provided" do
    expect do
      relation.create(username: 'tomas', email: 'tomas@test.cz')
    end.not_to raise_exception
  end

  it 'succeeds if optional attributes are nil' do
    expect do
      relation.create(username: 'tomas', email: 'tomas@test.cz', first_name: nil, last_name: nil)
    end.not_to raise_exception
  end

  it "fails if required attributes aren't provided" do
    expect do
      relation.create(first_name: 'Tomáš', last_name: 'Marný')
    end.to raise_exception SDM::ValidationError, /email is missing/
  end

  it 'fails if required attributes are nil' do
    expect do
      relation.create(first_name: 'Tomáš', last_name: 'Marný', username: nil, email: nil)
    end.to raise_exception SDM::ValidationError, /nil \(NilClass\) has invalid type for :username/
  end

  it 'fails if string attributes are provided non-string values' do
    expect do
      relation.create(username: 1, email: 2)
    end.to raise_exception SDM::ValidationError, /1 \(Integer\) has invalid type for :username/
  end

  it 'fails if string attributes are provided too long' do
    expect do
      relation.create(username: 'tomas', email: "#{'a' * 100}@test.cz")
    end.to raise_exception SDM::ValidationError
  end

  it 'fails if email has incorrect format' do
    expect do
      relation.create(username: 'tomas', email: 'non-email')
    end.to raise_exception SDM::ValidationError
  end

  it 'fails if given extra attributes' do
    expect do
      relation.create(username: 'tomas', email: 'tomas@test.cz', extra: true)
    end.to raise_exception SDM::ValidationError
  end
end
