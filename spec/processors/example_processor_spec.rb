# frozen_string_literal: true

RSpec.describe Processors::Example do
  let(:fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/example_statement.csv')
  end
  let(:subject) { Processors::Example.new(filepath: fixture_path) }

  before(:example) do
    subject.to_ynab!
  end

  it 'instantiates' do
    expect(subject).to be_kind_of(Processors::Processor)
  end

  it 'converts the statement' do
    actual = File.read(File.join(File.dirname(__dir__), '..',
                                 'example_20191223-20200202_ynab4.csv'))
    expected = <<~CSV
      "Date","Payee","Memo","Outflow","Inflow"
      "2019-12-23","coaxial","","1000000.0",""
      "2019-12-30","Santa","","50000.0",""
      "2020-02-02","Someone Else","","45.0",""
    CSV

    expect(actual).to eq(expected)
  end
end
