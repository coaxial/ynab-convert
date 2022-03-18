# frozen_string_literal: true

RSpec.describe Transformers::Cleaners::Cleaner do
  let(:cleaner) { described_class.new }

  it 'instantiates' do
    expect(cleaner).to be_an_instance_of(described_class)
  end

  it 'has a `run` method' do
    expect(cleaner).to respond_to(:run)
  end
end
