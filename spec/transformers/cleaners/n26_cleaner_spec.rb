# frozen_string_literal: true

RSpec.describe Transformers::Cleaners::N26 do
  let(:statement) do
    csv_statement = <<~CSV
      Date,Payee,Memo,Amount
      "2022/01/20","Amel MaruMaru","","200000"
      "2022/02/11","Hallberg-Rassy","","-120000"
    CSV
    CSV.parse(csv_statement, headers: true)
  end

  let(:subject) { Transformers::Cleaners::N26.new }

  it 'inherits from Cleaner' do
    expect(subject).to be_kind_of(Transformers::Cleaners::Cleaner)
  end

  it 'cleans rows' do
    # to_h makes it simpler to compare actual and expected; it avoids the
    # verbose creation of an array of CSV::Row to build the `expected` array.
    actual = statement.reduce([]) { |acc, row| acc << subject.run(row).to_h }
    expected = [
      { 'Date' => '2022/01/20', 'Payee' => 'Amel MaruMaru', 'Memo' => '',
        'Amount' => '200000' },
      { 'Date' => '2022/02/11', 'Payee' => 'Hallberg-Rassy', 'Memo' => '',
        'Amount' => '-120000' }
    ]

    expect(actual).to eq(expected)
  end
end
