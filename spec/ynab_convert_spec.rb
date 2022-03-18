# frozen_string_literal: true

RSpec.describe YnabConvert do
  let(:fixture_path) { 'spec/fixtures/statements/example_statement.csv' }
  let(:ynab_filename) { 'example_20191223-20200202_ynab4.csv' }

  it 'has a version number' do
    expect(YnabConvert::VERSION).not_to be nil
  end

  context 'when run from the command line' do
    it 'converts the csv file' do
      system("bin/ynab_convert -f #{fixture_path} -i example")

      actual = File.read(ynab_filename)
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "2019-12-23","coaxial","","1000000.0",""
        "2019-12-30","Santa","","50000.0",""
        "2020-02-02","Someone Else","","45.0",""
      ROWS

      expect(actual).to eq(expected)
    end
  end

  describe YnabConvert::Metadata do
    before do
      @subject = described_class.new
    end

    it 'can show a short description' do
      expected = 'An utility to convert online banking CSV files to a format' \
    " that can be imported into YNAB 4.\n"

      expect { @subject.short_desc }.to output(expected).to_stdout
    end

    it 'can show its version' do
      expected = "YNAB Convert #{YnabConvert::VERSION}\n"

      expect { @subject.version }.to output(expected).to_stdout
    end
  end

  describe YnabConvert::File do
    context 'with an existing file' do
      context 'that is valid CSV' do
        before do
          filename = File.join(File.dirname(__dir__), fixture_path)
          opts = { file: filename, processor: Processors::Example }
          @subject = described_class.new opts
        end

        it 'converts it' do
          @subject.to_ynab!
          actual = File.read(ynab_filename)
          expected = <<~ROWS
            "Date","Payee","Memo","Outflow","Inflow"
            "2019-12-23","coaxial","","1000000.0",""
            "2019-12-30","Santa","","50000.0",""
            "2020-02-02","Someone Else","","45.0",""
          ROWS

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
