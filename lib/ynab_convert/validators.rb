# frozen_string_literal: true

# Regroups all the row validators
module Validators
  # Load all known Validators
  Dir[File.join(__dir__, 'validators', '*.rb')].sort.each do |file|
    require file
  end
end
