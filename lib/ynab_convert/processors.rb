# frozen_string_literal: true

# Load all known processors
Dir[File.join(__dir__, 'processor', '*.rb')].each { |file| require file }
