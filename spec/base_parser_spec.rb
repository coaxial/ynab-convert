# frozen_string_literal: true

RSpec.describe Parser::Base do
  context 'with any CSV file' do
    before(:context) do
      @file = 'dummy.csv'
      @institution_name = 'Mesa Credit Union'
      @subject = Parser::Base.new(file: @file,
                                  institution_name: @institution_name)
    end

    it 'should initialize' do
      expect(@subject).to be_an_instance_of(Parser::Base)
    end

    it 'should compute the right output filename' do
      from = Time.local(1986, 'jul', 25, 0, 30, 0)
      to = Time.local(1986, 'nov', 12, 5, 0, 0)
      actual = @subject.send(:output_filename, from: from, to: to)
      expected = "#{File.basename(@file, '.csv')}_" \
        "#{@institution_name.snake_case}_#{from.strftime('%Y%m%d')}-" \
        "#{to.strftime('%Y%m%d')}_ynab4.csv"

      expect(actual).to eq(expected)
    end

    it "has a `to_ynab!' method" do
      expect(@subject).to respond_to(:to_ynab!)
    end
  end
end
