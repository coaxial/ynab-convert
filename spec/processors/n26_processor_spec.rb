# frozen_string_literal: true

require 'ynab_convert/processors/n26_processor'

RSpec.describe Processors::N26 do
  let(:fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/documents/statements/n26/n26.csv')
  end
  let(:subject) { Processors::N26.new(filepath: fixture_path) }

  it 'instantiates' do
    expect(subject).to be_kind_of(Processors::Processor)
  end
end
