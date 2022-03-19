# frozen_string_literal: true

RSpec.describe Documents::YNAB4Files::YNAB4File do
  let(:ynab4_file) do
    described_class.new(
      institution_name: 'Test Bank'
    )
  end

  before do
    rows = [
      %w[2022/03/08,Test Payee 3 42.0],
      %w[2022/01/01,Test Payee 1 1337.0],
      %w[2022/03/09,Test Payee 2 666.0]
    ]
    rows.each do |r|
      ynab4_file.update_dates(r)
    end
  end

  it 'instantiates' do
    expect(ynab4_file).to be_an_instance_of(described_class)
  end

  context 'when the format isn\'t specified' do
    it 'uses :flows' do
      actual = ynab4_file.csv_export_options[:headers]
      expected = %w[Date Payee Memo Outflow Inflow]

      expect(actual).to eq(expected)
    end
  end

  context 'when the format is set to :amounts' do
    let(:ynab4_file) do
      described_class.new(format: :amounts,
                          institution_name: 'Test Bank')
    end

    it 'uses :amounts' do
      actual = ynab4_file.csv_export_options[:headers]
      expected = %w[Date Payee Memo Amount]

      expect(actual).to eq(expected)
    end
  end

  it 'generates the correct filename' do
    expected = 'test_bank_20220101-20220309_ynab4.csv'

    expect(ynab4_file.filename).to eq(expected)
  end
end
