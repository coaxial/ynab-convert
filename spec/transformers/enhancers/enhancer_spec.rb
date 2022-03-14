# frozen_string_literal: true

require 'ynab_convert/transformers/enhancers/enhancer'

RSpec.describe Enhancers::Enhancer do
  let(:subject) { Enhancers::Enhancer.new }

  it 'instantiates' do
    expect(subject).to be_an_instance_of(Enhancers::Enhancer)
  end

  it 'has a `run` method' do
    expect(subject).to respond_to(:run)
  end
end
