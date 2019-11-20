# frozen_string_literal: true

require 'bundler/setup'
require 'pry-byebug'
require 'ynab_convert'
require 'ynab_convert/processor/base'

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
end
