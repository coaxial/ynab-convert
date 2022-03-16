# frozen_string_literal: true

# Regroups all the classes involved in transforming a given Statement into a
# YNAB4File
module Transformers
  transformers = %w[cleaner enhancer formatter]

  # Load all known Transformers
  transformers.each do |t|
    # Require the base classes first so that its children can find the parent
    # class since files are otherwise loaded in alphabetical order
    require File.join(__dir__, 'transformers', "#{t}s", "#{t}.rb")

    Dir[File.join(__dir__, 'transformers', "#{t}s", '*.rb')].each do |file|
      require file
    end
  end
end
