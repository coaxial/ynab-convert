# frozen_string_literal: true

RSpec.describe Processors::Processor do
  let(:fixture_filepath) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/statement.csv')
  end

  context 'with custom converters' do
    before do
      options = { statement: nil, ynab4_file: nil, converters: {
        test_converter: ->(s) { s }
      }, transformers: [] }

      described_class.new(options)
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
    let(:cleaner) { object_double(Transformers::Cleaners::Cleaner.new) }
    let(:processor) do
      options = { statement: statement, ynab4_file: ynab4_file,
                  converters: {}, transformers: [cleaner] }

      described_class.new(options)
    end

    before do
      allow(statement).to receive(:institution_name).and_return('Test')
      allow(ynab4_file).to receive(:filename).and_return('test_ynab4.csv')
      allow(cleaner).to receive(:run) { |row| row }

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
      csv_import_options = { col_sep: ';', quote_char: nil, headers: true }
      test_class = Class.new(Documents::Statements::Statement)
      stub_const('Documents::Statements::Test', test_class)

      test_class.new(filepath: fixture_filepath,
                     csv_import_options: csv_import_options)
    end

    let(:ynab4_file) do
      Documents::YNAB4Files::YNAB4File.new(institution_name: 'Test')
    end
    let(:processor) do
      cleaner = Transformers::Cleaners::Cleaner
      allow(cleaner).to receive(:run) { |row| row }
      formatter = Transformers::Formatters::Formatter
      allow(formatter).to receive(:run) { |row| row }
      enhancer = Transformers::Enhancers::Enhancer
      allow(enhancer).to receive(:run) { |row| row }

      transformers = [cleaner, formatter, enhancer]
      options = {
        statement: statement, ynab4_file: ynab4_file, transformers:
transformers
      }

      described_class.new(options)
    end
    let(:processed) do
      <<~CSV
        "Date","Payee","Memo","Outflow","Inflow"
        "2019-12-23","Chequing","coaxial","1000000.0","","12000000"
        "2019-12-30","Chequing","Santa","50000.0","","11950000"
        "2020-02-02","Chequing","Someone Else","45.0","","11949955"
      CSV
    end

    before { processor.to_ynab! }

    it 'processes the statement' do
      actual = File.read(File.join(File.dirname(__dir__), '..',
                                   'test_20191223-20200202_ynab4.csv'))

      expect(actual).to eq(processed)
    end
  end
end
