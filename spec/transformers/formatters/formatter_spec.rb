# frozen_string_literal: true

RSpec.describe Transformers::Formatters::Formatter do
  it 'instantiates' do
    formatter = described_class.new(date: [0], payee:
                                                      [1], memo: [2],
                                    amount: [3])
    expect(formatter).to be_kind_of(described_class)
  end

  context 'when Statement fields and YNAB4 fields match 1:1' do
    let(:statement) do
      csv_statement = <<~CSV
        date,payee,memo,amount
        "2022-03-10","Test Payee","","13.37"
      CSV
      options = { col_sep: ',', quote_char: '"', headers: true }
      CSV.parse(csv_statement, options)
    end

    let(:formatter) do
      described_class.new(date: [0], payee: [1], memo: [2],
                          amount: [3])
    end

    it 'formats rows' do
      actual = statement.reduce([]) { |acc, row| acc << formatter.run(row) }
      expected = [['2022-03-10', 'Test Payee', '', '13.37']]

      expect(actual).to eq(expected)
    end
  end

  context 'when Statement fields and YNAB4 fields don\'t match 1:1' do
    let(:statement) do
      csv_statement = <<~CSV
        date,payee1,payee2,memo,amount
        "2022-03-10","Test","Payee","","13.37"
      CSV
      options = { col_sep: ',', quote_char: '"', headers: true }
      CSV.parse(csv_statement, options)
    end

    let(:formatter) do
      described_class.new(date: [0], payee: [1, 2],
                          memo: [3], amount: [4])
    end

    it 'formats rows' do
      actual = statement.reduce([]) { |acc, row| acc << formatter.run(row) }
      expected = [['2022-03-10', 'Test Payee', '', '13.37']]

      expect(actual).to eq(expected)
    end
  end

  context 'when there is no memo field' do
    let(:statement) do
      csv_statement = <<~CSV
        date,payee1,payee2,amount
        "2022-03-10","Test","Payee","13.37"
      CSV
      options = { col_sep: ',', quote_char: '"', headers: true }
      CSV.parse(csv_statement, options)
    end

    let(:formatter) do
      described_class.new(date: [0], payee: [1, 2],
                          memo: [], amount: [3])
    end

    it 'formats rows' do
      actual = statement.reduce([]) { |acc, row| acc << formatter.run(row) }
      expected = [['2022-03-10', 'Test Payee', '', '13.37']]

      expect(actual).to eq(expected)
    end
  end

  context 'with a :flows statement' do
    let(:statement) do
      csv_statement = <<~CSV
        date,payee,memo,outflow,inflow
        "2022-03-10","Test Payee","","13.37",""
        "2022-03-10","Test Credit","","","6.66"
      CSV
      options = { col_sep: ',', quote_char: '"', headers: true }
      CSV.parse(csv_statement, options)
    end
    let(:expected) do
      [
        ['2022-03-10', 'Test Payee', '', '13.37', ''],
        ['2022-03-10', 'Test Credit', '', '', '6.66']
      ]
    end
    let(:formatter) do
      described_class.new(date: [0], payee: [1], memo: [2], outflow: [3],
                          inflow: [4])
    end

    it 'formats rows' do
      actual = statement.reduce([]) { |acc, row| acc << formatter.run(row) }

      expect(actual).to eq(expected)
    end
  end
end
