# frozen_string_literal: true

# Base processor must be loaded first as all others inherit from it
require 'ynab_convert/processors/processor'

# Load all known processors
Dir[File.join(__dir__, 'processors', '*.rb')].each { |file| require file }
