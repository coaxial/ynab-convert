# frozen_string_literal: true

require 'ynab_convert/processors/n26_processor'

RSpec.describe Processors::N26, :vcr do
  let(:fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/n26.csv')
  end
  let(:subject) { Processors::N26.new(filepath: fixture_path) }

  before(:example) do
    subject.to_ynab!
  end

  it 'instantiates' do
    expect(subject).to be_kind_of(Processors::Processor)
  end

  it 'converts the statement' do
    actual = File.read(File.join(File.dirname(__dir__), '..',
                                 'n26_20220120-20220211_ynab4.csv'))
    expected = <<~CSV
      "Date","Payee","Memo","Amount"
      "2022-01-20","Amel MaruMaru","","207741.8"
      "2022-02-11","Hallberg-Rassy","","-126671.04"
    CSV

    expect(actual).to eq(expected)
  end
end
