# frozen_string_literal: true

require 'ynab_convert/transformers/cleaners/cleaner'

RSpec.describe Transformers::Cleaners::Cleaner do
  let(:subject) { Transformers::Cleaners::Cleaner.new }

  it 'instantiates' do
    expect(subject).to be_an_instance_of(Transformers::Cleaners::Cleaner)
  end

  it 'has a `run` method' do
    expect(subject).to respond_to(:run)
  end
end
