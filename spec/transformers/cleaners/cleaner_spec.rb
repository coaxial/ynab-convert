# frozen_string_literal: true

require 'ynab_convert/transformers/cleaners/cleaner'

RSpec.describe Cleaners::Cleaner do
  let(:subject) { Cleaners::Cleaner.new }

  it 'instantiates' do
    expect(subject).to be_an_instance_of(Cleaners::Cleaner)
  end

  it 'has a `parse` method' do
    expect(subject).to respond_to(:parse)
  end
end
