require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Adrift'
  rdoc.main     = 'README.rdoc'

  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec
