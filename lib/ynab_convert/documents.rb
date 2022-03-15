# frozen_string_literal: true

# Groups Statements and YNAB4File
module Documents
  documents = %w[statements ynab4_files]

  # Load all known Documents
  documents.each do |document|
    Dir[File.join(__dir__, 'documents', document, '*.rb')].each do |file|
      require file
    end
  end
end
