# frozen_string_literal: true

module Documents
  documents = %w[statements ynab4_files]

  # Load all known Documents
  documents.each do |document|
    Dir[File.join(__dir__, document, '*.rb')].each { |file| require file }
  end
end
