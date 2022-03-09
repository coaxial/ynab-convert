# frozen_string_literal: true

require 'ynab_convert/documents/statements/statement'

RSpec.describe Documents::Statements::Statement do
  context 'with an existing CSV statement' do
    csv_path = File.join(
      File.dirname(__FILE__),
      '..',
      '..',
      'fixtures/documents/statements/statement.csv'
    )

    let(:subject) { Documents::Statements::Statement.new(filepath: csv_path) }

    it 'instantiates' do
      expect(subject).to be_an_instance_of(Documents::Statements::Statement)
    end

    context 'when given custom CSV import options' do
      custom_options = { col_sep: ';' }
      let(:subject) do
        Documents::Statements::Statement.new(
          filepath: csv_path,
          csv_import_options: custom_options
        )
      end

      it 'exposes the options' do
        expected = custom_options
        actual = subject.csv_import_options

        expect(actual).to eq(expected)
      end
    end

    it 'exposes the CSV statement\'s path' do
      expected = csv_path
      actual = subject.filepath

      expect(actual).to eq(expected)
    end
  end

  context 'with a non-existent CSV statement' do
    let(:subject) do
      lambda {
        Documents::Statements::Statement.new(
          filepath: 'nope.csv'
        )
      }
    end
    it 'raises' do
      expect(&subject).to raise_error(Errno::ENOENT)
    end
  end
end
