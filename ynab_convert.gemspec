# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ynab_convert/version'

Gem::Specification.new do |spec|
  spec.name          = 'ynab_convert'
  spec.version       = YnabConvert::VERSION
  spec.authors       = ['coaxial']
  spec.email         = ['hi@64b.it']

  spec.summary       = 'Convert online banking CSV files to YNAB 4 format.'
  spec.homepage      = 'https://github.com/coaxial/ynab_convert'
  spec.license       = 'MIT'
  spec.description   = <<~DESC
    Utility to convert CSV statements into the YNAB4 format for easier
    transation import. Supports several banks and can easily be extended to
    add more.
  DESC

  spec.required_ruby_version = '~> 2.6'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/coaxial/ynab_convert/issues',
    'documentation_uri' => 'https://rubydoc.info/github/coaxial/ynab_convert/master',
    'homepage_uri' => 'https://github.com/coaxial/ynab_convert',
    'source_code_uri' => 'https://github.com/coaxial/ynab_convert'
  }
  spec.post_install_message = 'Happy budgetting!'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/coaxial/ynab_convert'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-core'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'solargraph'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'i18n'
  spec.add_dependency 'slop'
  spec.add_dependency 'timecop'
end
