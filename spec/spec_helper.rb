# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'bundler/setup'
require 'pry-byebug'
require 'ynab_convert/processors'
require 'ynab_convert'
require 'ynab_convert/error'
require 'slop/symbol'
require 'vcr_setup'

RSpec.configure do |config|
  include CoreExtensions::String::Inflections
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Run only specific tests by adding :focus
  config.filter_run_when_matching focus: true

  # Automatically cleanup generated CSV files
  config.after(:example, writes_csv: true) do
    Dir.glob('*.csv').each { |f| File.delete(f) }
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end

RSpec::Matchers.define :exit_with_code do |expected|
  actual = nil
  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end

    actual && (actual == expected)
  end

  supports_block_expectations

  failure_message_for_should do |_block|
    "Expected exit with code #{expected}, got #{actual} instead."
  end

  failure_message_when_negated do |_block|
    "expected not to exit with code #{expected}"
  end

  description do
    "expect block to exit with #{expected}."
  end
end
