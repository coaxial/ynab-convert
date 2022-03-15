# frozen_string_literal: true

require 'ynab_convert/documents'
require 'ynab_convert/transformers'
require 'ynab_convert/processors/processor'

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
    let(:statement) do
      Documents::Statements::Statement.new(filepath: fixture_filepath)
    end
    let(:ynab4_file) do
      Documents::YNAB4Files::YNAB4File.new(institution_name: 'Test')
    end
    let(:cleaner) { spy(Transformers::Cleaners::Cleaner) }
    let(:processor) do
      options = { statement: statement, ynab4_file: ynab4_file,
                  converters: {}, transformers: [cleaner] }

      Processors::Processor.new(options)
    end

    before(:example) do
      allow(statement).to receive(:institution_name).and_return('Test')
      allow(ynab4_file).to receive(:filename).and_return('test_ynab4.csv')

      processor.to_ynab!
    end

    it 'runs each transformer' do
      # There are six rows in the fixture statement, so the transformer
      # should have run six times
      expect(cleaner).to have_received(:run).exactly(6).times
    end
  end

  context 'with a valid statement' do
    let(:statement) do
      module Documents
        module Statements
          class Test < Statement
            def initialize(filepath:)
              csv_import_options = { col_sep: ';', headers: true }

              super(filepath: filepath, csv_import_options: csv_import_options)
            end
          end
        end
      end

      Documents::Statements::Test.new(filepath: fixture_filepath)
    end

    let(:ynab4_file) do
      Documents::YNAB4Files::YNAB4File.new(institution_name: 'Test')
    end
    let(:subject) do
      # TODO: see if instance_double can be removed altogether
      mock_cleaner = instance_double(Transformers::Cleaners::Cleaner)
      allow(mock_cleaner).to receive(:run) { |row| row }
      mock_formatter = instance_double(Transformers::Formatters::Formatter)
      allow(mock_formatter).to receive(:run) { |row| row }
      mock_enhancer = instance_double(Transformers::Enhancers::Enhancer)
      allow(mock_enhancer).to receive(:run) { |row| row }

      transformers = [mock_cleaner, mock_formatter, mock_enhancer]
      options = {
        statement: statement, ynab4_file: ynab4_file, transformers:
transformers
      }

      Processors::Processor.new(options)
    end

    before(:example) do
      subject.to_ynab!
    end

    it 'processes the statement' do
      actual = File.read(File.join(File.dirname(__dir__), '..',
                                   'test_20191223-20200202_ynab4.csv'))
      expected = <<~CSV
        "Date","Payee","Memo","Outflow","Inflow"
        "2019-12-23","Chequing","coaxial","1000000.00","","12000000"
        "2019-12-30","Chequing","Santa","50000.00","","11950000"
        "2020-02-02","Chequing","Someone Else","45.00","","11949955"
      CSV

      expect(actual).to eq(expected)
    end
  end
end
