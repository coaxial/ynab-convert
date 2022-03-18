# frozen_string_literal: true

RSpec.describe Transformers::Enhancers::Enhancer do
  let(:subject) { described_class.new }

  it 'instantiates' do
    expect(subject).to be_an_instance_of(described_class)
  end

  it 'has a `run` method' do
    expect(subject).to respond_to(:run)
  end
end
