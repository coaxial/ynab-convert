# frozen_string_literal: true

require 'ynab_convert/documents'

RSpec.describe Documents::YNAB4Files::YNAB4File do
  let(:subject) do
    Documents::YNAB4Files::YNAB4File.new(
      institution_name: 'Test Bank'
    )
  end

  it 'instantiates' do
    expect(subject).to be_an_instance_of(Documents::YNAB4Files::YNAB4File)
  end

  context 'when the format isn\'t specified' do
    it 'uses :flows' do
      actual = subject.csv_export_options[:headers]
      expected = %w[Date Payee Memo Outflow Inflow]

      expect(actual).to eq(expected)
    end
  end

  context 'when the format is set to :amounts' do
    let(:subject) do
      Documents::YNAB4Files::YNAB4File.new(format: :amounts,
                                           institution_name: 'Test Bank')
    end

    it 'uses :amounts' do
      actual = subject.csv_export_options[:headers]
      expected = %w[Date Payee Memo Amount]

      expect(actual).to eq(expected)
    end
  end

  it 'generates the correct filename' do
    rows = [
      %w[2022/03/08,Test Payee 3 42.0],
      %w[2022/01/01,Test Payee 1 1337.0],
      %w[2022/03/09,Test Payee 2 666.0]
    ]
    rows.each do |r|
      subject.update_dates(r)
    end

    actual = subject.filename
    expected = 'test_bank_20220101-20220309_ynab4.csv'

    expect(actual).to eq(expected)
  end
end
