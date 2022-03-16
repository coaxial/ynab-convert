# frozen_string_literal: true

# Groups Statements and YNAB4File
module Documents
  documents = %w[statement ynab4_file]

  # Load all known Documents
  documents.each do |d|
    # Require the base classes first so that its children can find the parent
    # class since files are otherwise loaded in alphabetical order
    require File.join(__dir__, 'documents', "#{d}s", "#{d}.rb")

    Dir[File.join(__dir__, 'documents', "#{d}s", '*.rb')].each do |file|
      require file
    end
  end
end
