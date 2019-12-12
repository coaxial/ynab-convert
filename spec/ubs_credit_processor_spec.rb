# frozen_string_literal: true

RSpec.describe(Processor::UbsCredit) do
  fixture_path = 'fixtures/ubs_credit/statement.csv'

  context('with any file') do
    before(:context) do
      @subject = Processor::UbsCredit.new(
        file: File.join(File.dirname(__FILE__), fixture_path)
      )
    end

    it 'instantiates' do
      expect(@subject).to be_an_instance_of(Processor::UbsCredit)
    end

    it 'inherits from Processor::Base' do
      expect(@subject).to be_kind_of(Processor::Base)
    end
  end

  context 'with a valid CSV file' do
    before(:context) do
      filename = File.join(File.dirname(__FILE__), fixture_path)
      @subject = Processor::UbsCredit.new(file: filename)
    end

    # it 'outputs valid YNAB4 CSV data', :writes_csv do
    it 'outputs valid YNAB4 CSV data' do
      @subject.to_ynab!
      actual = File.read(
        'statement_ubs_credit_cards_20191028-20191111_ynab4.csv'
      )
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "28/10/2019","TWINT  *Post CH AG       St. Moritz   CHE","","1215.00",""
        "02/11/2019","Revolut*1234*            revolut.com  GBR","","2500.00",""
        "04/11/2019","Revolut*1234*            revolut.com  GBR","","2500.00",""
        "06/11/2019","TWINT  *Some Company     Renens       CHE","","199.00",""
        "07/11/2019","Revolut*1234*            revolut.com  GBR","","300.00",""
        "07/11/2019","TWINT  *SBB Mobile       Bern         CHE","","2.20",""
        "11/11/2019","Revolut*1234*            revolut.com  GBR","","130.00",""
        "11/11/2019","Revolut*1234*            revolut.com  GBR","","500.00",""
        "11/11/2019","Revolut*1234*            revolut.com  GBR","","1000.00",""
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
