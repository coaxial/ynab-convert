# frozen_string_literal: true

require 'helpers/dummy_parser.rb'

RSpec.describe(Parser::Dummy) do
  context('with any file') do
    before(:context) do
      @subject = Parser::Dummy.new(file: 'a_file')
    end

    it 'instantiates' do
      expect(@subject).to be_an_instance_of(Parser::Dummy)
    end

    it 'inherits from Parser::Base' do
      expect(@subject).to be_kind_of(Parser::Base)
    end
  end

  context 'with a valid CSV file' do
    before(:context) do
      filename = File.join(File.dirname(__FILE__), 'fixtures/valid.csv')
      @subject = Parser::Dummy.new(file: filename)
    end

    it 'outputs valid YNAB4 CSV data', :writes_csv do
      @subject.to_ynab!
      actual = File.read('valid_dummy_bank_20191223-20200202_ynab4.csv')
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "23/12/2019","coaxial","","1000000.00",""
        "02/02/2020","Someone Else","","45.00",""
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
