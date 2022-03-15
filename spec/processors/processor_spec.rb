# frozen_string_literal: true

require 'ynab_convert/documents/statements/statement'
require 'ynab_convert/processors/processor'
require 'ynab_convert/transformers/cleaners/cleaner'

RSpec.describe Processors::Processor do
  let(:fixture_filepath) do
    File.join(File.dirname(__dir__),
              'fixtures/documents/statements/statement.csv')
  end

  after(:example) do
    FileUtils.rm(Dir.glob('statement_test*'))
  end

  context 'with custom converters' do
    before(:example) do
      options = { statement: nil, ynab4_file: nil, converters: {
        test_converter: ->(s) { s }
      }, transformers: [] }

      Processors::Processor.new(options)
    end

    it 'registers customer converters' do
      expect(CSV::Converters.key?(:test_converter)).to be(true)
    end
  end

  context 'with transformers' do
    let(:statement) { instance_double(Statements::Statement) }
    let(:ynab4_file) { instance_double(YNAB4Files::YNAB4File) }
    let(:cleaner) { spy(Cleaners::Cleaner) }
    let(:processor) do
      options = { statement: statement, ynab4_file: ynab4_file,
                  converters: {}, transformers: [cleaner] }

      Processors::Processor.new(options)
    end

    before(:example) do
      allow(statement).to receive(:institution_name).and_return('Test')
      allow(statement).to receive(:filepath).and_return(fixture_filepath)
      allow(statement).to receive(:csv_import_options).and_return({})
      allow(ynab4_file).to receive(:csv_export_options).and_return({})

      processor.to_ynab!
    end

    it 'runs each transformer' do
      # There are five rows in the fixture statement, so the transformer
      # should have run five times
      expect(cleaner).to have_received(:run).exactly(5).times
    end
  end
end
