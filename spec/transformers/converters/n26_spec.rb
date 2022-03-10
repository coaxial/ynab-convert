# frozen_string_literal: true

require 'ynab_convert/transformers/converters/converter'
require 'ynab_convert/transformers/converters/n26'

RSpec.describe Converters::N26 do
  let(:subject) { Converters::N26.new }

  it 'inherits from Converter' do
    expect(subject).to be_kind_of(Converters::Converter)
  end
end
