# frozen_string_literal: true

RSpec.describe YnabConvert do
  let(:fixture_path) { 'spec/fixtures/statements/example_statement.csv' }
  let(:ynab_filename) { 'example_20191223-20200202_ynab4.csv' }
  let(:converted) do
    <<~ROWS
      "Date","Payee","Memo","Outflow","Inflow"
      "2019-12-23","coaxial","","1000000.0",""
      "2019-12-30","Santa","","50000.0",""
      "2020-02-02","Someone Else","","45.0",""
    ROWS
  end

  it 'has a version number' do
    expect(YnabConvert::VERSION).not_to be nil
  end

  context 'when run from the command line' do
    it 'converts the csv file' do
      system("bin/ynab_convert -f #{fixture_path} -i example")

      actual = File.read(ynab_filename)

      expect(actual).to eq(converted)
    end
  end

  describe YnabConvert::Metadata do
    let(:metadata) { described_class.new }

    it 'can show a short description' do
      expected = 'An utility to convert online banking CSV files to a format' \
    " that can be imported into YNAB 4.\n"

      expect { metadata.short_desc }.to output(expected).to_stdout
    end

    it 'can show its version' do
      expected = "YNAB Convert #{YnabConvert::VERSION}\n"

      expect { metadata.version }.to output(expected).to_stdout
    end
  end

  describe YnabConvert::File do
    context 'with an existing file containing valid CSV' do
      let(:converted) do
        <<~ROWS
          "Date","Payee","Memo","Outflow","Inflow"
          "2019-12-23","coaxial","","1000000.0",""
          "2019-12-30","Santa","","50000.0",""
          "2020-02-02","Someone Else","","45.0",""
        ROWS
      end
      let(:file) do
        filename = File.join(File.dirname(__dir__), fixture_path)
        opts = { file: filename, processor: Processors::Example }
        described_class.new opts
      end

      before { file.to_ynab! }

      it 'converts it' do
        actual = File.read(ynab_filename)

        expect(actual).to eq(converted)
      end
    end
  end
end
