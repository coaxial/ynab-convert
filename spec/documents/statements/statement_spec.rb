# frozen_string_literal: true

RSpec.describe Documents::Statements::Statement do
  context 'with an existing CSV statement' do
    let(:csv_path) do
      File.join(File.dirname(__dir__), '..',
                'fixtures/statements/statement.csv')
    end

    let(:test_statement) do
      # Defining a Documents::Statements::Test class properly nested in modules
      # so that .class.name contains all the namespaces
      # test_class = class Test < Documents::Statements::Statement; end
      test_class = Class.new(described_class)
      stub_const('Documents::Statements::Test', test_class)

      test_class.new(filepath: csv_path)
    end

    it 'has an institution name' do
      expect(test_statement.institution_name).to eq('Test')
    end

    context 'when given custom CSV import options' do
      let(:custom_options) { { col_sep: ';' } }
      let(:test_statement) do
        described_class.new(
          filepath: csv_path,
          csv_import_options: custom_options
        )
      end

      it 'exposes the options' do
        default_options = CSV::DEFAULT_OPTIONS.merge(converters: %i[numeric
                                                                    date])
        expected = default_options.merge(custom_options)
        actual = test_statement.csv_import_options

        expect(actual).to eq(expected)
      end
    end

    it 'exposes the CSV statement\'s path' do
      expected = csv_path
      actual = test_statement.filepath

      expect(actual).to eq(expected)
    end
  end

  context 'with a non-existent CSV statement' do
    let(:test_statement) do
      lambda {
        described_class.new(
          filepath: 'nope.csv'
        )
      }
    end

    it 'raises' do
      expect(&test_statement).to raise_error(Errno::ENOENT)
    end
  end
end
