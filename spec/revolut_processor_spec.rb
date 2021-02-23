# frozen_string_literal: true

RSpec.describe(Processor::Revolut) do
  context('with any file') do
    before(:context) do
      @subject = Processor::Revolut.new(
        file: File.join(File.dirname(__FILE__),
                        'fixtures/revolut/statement.csv')
      )
    end

    it 'instantiates' do
      expect(@subject).to be_an_instance_of(Processor::Revolut)
    end

    it 'inherits from Processor::Base' do
      expect(@subject).to be_kind_of(Processor::Base)
    end
  end

  context 'with a valid CSV file' do
    before(:context) do
      file = File.join(File.dirname(__FILE__), 'fixtures/revolut/statement.csv')
      @subject = Processor::Revolut.new(file: file)
    end

    # it 'outputs valid YNAB4 CSV data', :writes_csv do
    it 'outputs valid YNAB4 CSV data', :writes_csv do
      @subject.to_ynab!
      # Revolut statements don't include the year. When parsing the date, it
      # will assume current year. This will change each year, so it must be
      # computed when the test is executed.
      current_year = Date.today.year
      actual = File.read(
        "statement_revolut_#{current_year}1102-#{current_year}1206_ynab4.csv"
      )
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "06/12/#{current_year}","Auto Top-Up by *1234","","","100.00"
        "05/12/#{current_year}","To Bruce Wayne","","20.84",""
        "02/12/#{current_year}","Rigmarole Ltd.","","1106.72",""
        "02/12/#{current_year}","Top-Up by *1234","","","1100.00"
        "02/12/#{current_year}","Auto Top-Up by *1234","","","100.00"
        "02/12/#{current_year}","Exchanged to EUR","","153.14",""
        "02/12/#{current_year}","Top-Up by *1234","","","50.00"
        "06/11/#{current_year}","Payee 3326","","2.53",""
        "04/11/#{current_year}","Payee 391","","58.68",""
        "04/11/#{current_year}","Top-Up by *1234","","","50.00"
        "02/11/#{current_year}","Top-Up by *1234","","","50.00"
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
