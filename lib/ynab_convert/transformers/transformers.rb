# frozen_string_literal: true

# Regroups all the classes involved in transforming a given Statement into a
# YNAB4File
module Transformers
  transformers = %w[cleaners converters enhancers]

  # Load all known Transformers
  transformers.each do |transformer|
    Dir[File.join(__dir__, transformer, '*.rb')].each { |file| require file }
  end
end
