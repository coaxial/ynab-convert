# frozen_string_literal: true

RSpec.describe YnabConvert::Config do
  # The file is at ./ynab_convert.yml when testing
  let(:config_file_location) do
    File.join(
      File.dirname(File.expand_path(__dir__)),
      'ynab_convert.yml'
    )
  end
  let(:default_config_file_location) do
    File.join(
      File.expand_path('..', File.dirname(__FILE__)),
      'lib',
      'ynab_convert',
      'default_config.yml'
    )
  end

  before(:example) do
    File.write(
      config_file_location,
      File.read(default_config_file_location)
    )
  end

  after(:example) { File.delete(config_file_location) }

  let(:subject) { YnabConvert::Config.new }

  it 'has a config file location' do
    actual = subject.file_path
    expected = config_file_location

    expect(actual).to eq(expected)
  end

  it 'generates a default config' do
    actual = subject.default
    expected = File.read(default_config_file_location)

    expect(actual).to eq(expected)
  end

  it 'writes a default config file' do
    subject.write_default

    actual = File.read(config_file_location)
    expected = File.read(default_config_file_location)

    expect(actual).to eq(expected)
  end

  context 'for a given YnabConvert::Processor' do
    it 'returns the relevant configuration' do
      actual = subject.get(processor: :N26)
      expected = { TargetCurrency: 'CHF' }

      expect(actual).to eq(expected)
    end
  end
end
