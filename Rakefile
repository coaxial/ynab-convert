# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

desc 'Check code format'
RuboCop::RakeTask.new

desc 'Run tests and check code format'
task :ci do
  Rake::Task[:spec].invoke
  Rake::Task[:rubocop].invoke
end

task default: :ci
