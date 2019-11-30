# frozen_string_literal: true

require 'helpers/dummy_processor.rb'

RSpec.describe YnabConvert do
  it 'has a version number' do
    expect(YnabConvert::VERSION).not_to be nil
  end

  describe YnabConvert::Metadata do
    before(:example) do
      @subject = YnabConvert::Metadata.new
    end

    it 'can show a short description' do
      expected = 'A utility to convert online banking CSV files to a format' \
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
        before(:example) do
          filename = File.join(File.dirname(__FILE__), 'fixtures/valid.csv')
          opts = { file: filename, processor: Processor::Dummy }
          @subject = YnabConvert::File.new opts
        end

        it 'converts it', :writes_csv do
          @subject.to_ynab!
          actual = File.read('valid_dummy_bank_20191223-20200202_ynab4.csv')
          expected = <<~ROWS
            "Date","Payee","Memo","Outflow","Inflow"
            "23/12/2019","coaxial","","1000000.00",""
            "30/12/2019","Santa","","50000.00",""
            "02/02/2020","Someone Else","","45.00",""
          ROWS

          expect(actual).to eq(expected)
        end
      end

      context 'that is invalid CSV' do
        before(:example) do
          filename = File.join(File.dirname(__FILE__),
                               'fixtures/not_a_csv_file.txt')
          opts = { file: filename, processor: Processor::Dummy }
          @subject = -> { YnabConvert::File.new(opts) }
        end

        it 'prints an error message' do
          expect { @subject.call.to_ynab! }.to raise_error(RuntimeError,
                                                           /unable to parse/i)
        end

        it 'cleans up the temporary CSV file' do
          @subject.call.to_ynab!
        rescue RuntimeError
          expect(Dir['not_a_csv_file.txt_dummy_bank_*.csv'].any?).to be false
        end
      end
    end
  end
end
