# frozen_string_literal: true

RSpec.describe YnabConvert::Config do
  # The file is at ./ynab_convert.yml when testing
  let(:config_file_location) do
    File.join(
      File.dirname(File.expand_path(__dir__)),
      'ynab_convert.yml'
    )
  end

  # The default config file is at lib/ynab_convert/default_config.yml
  let(:default_config_file_location) do
    File.join(
      File.expand_path('..', File.dirname(__FILE__)),
      'lib',
      'ynab_convert',
      'default_config.yml'
    )
  end

  let(:subject) { YnabConvert::Config.new }

  after(:example) { FileUtils.rm_f(config_file_location) }

  it 'has a config file location' do
    actual = subject.user_file_path
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

  context 'when a config file already exists' do
    let(:custom_user_config) do
      <<~USRCONF
        ---
        Test custom user config
      USRCONF
    end

    before(:example) do
      File.write(config_file_location, custom_user_config)
    end

    it 'throws an error' do
      expect { subject.write_default }.to raise_error(Errno::EEXIST,
                                                      /already exists/)
    end
  end

  context 'for a given YnabConvert::Processor' do
    it 'returns the relevant configuration' do
      actual = subject.get(processor: :N26)
      expected = { TargetCurrency: 'CHF' }

      expect(actual).to eq(expected)
    end
  end
end
