# frozen_string_literal: true

RSpec.describe(Processor::N26) do
  context('with any file') do
    let(:subject) do
      Processor::N26.new(
        file: File.join(File.dirname(__FILE__),
                        'fixtures/n26/statement.csv'),
        format: :amounts
      )
    end

    it 'instantiates' do
      expect(subject).to be_an_instance_of(Processor::N26)
    end

    it 'inherits from Processor::Base' do
      expect(subject).to be_kind_of(Processor::Base)
    end
  end

  context 'with a valid CSV file' do
    let(:filename) do
      File.join(
        File.dirname(__FILE__),
        'fixtures/n26/statement.csv'
      )
    end
    let(:subject) { Processor::N26.new(file: filename, format: :amounts) }

    it 'outputs valid YNAB4 CSV data', :writes_csv do
      subject.to_ynab!
      actual = File.read('statement_n26_bank_20220120-20220211_ynab4.csv')
      expected = <<~ROWS
        "Date","Payee","Memo","Amount"
        "2022-01-20","Amel MaruMaru","","200000.0"
        "2022-02-11","Hallberg-Rassy","","-120000.0"
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
