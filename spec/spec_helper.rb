# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'ynab_convert'
require 'ynab_convert/parser/base'

RSpec.configure do |config|
  include CoreExtensions::String::Inflections
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Run only specific tests by adding :focus
  config.filter_run_when_matching focus: true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
