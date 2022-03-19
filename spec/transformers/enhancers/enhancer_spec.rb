# frozen_string_literal: true

RSpec.describe Transformers::Enhancers::Enhancer do
  let(:enhancer) { described_class.new }

  it 'instantiates' do
    expect(enhancer).to be_an_instance_of(described_class)
  end

  it 'has a `run` method' do
    expect(enhancer).to respond_to(:run)
  end
end
