require(File.join(File.dirname(__FILE__), 'config', 'boot'))  # added DJS

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails' # added DJS

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the community_engine plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the community_engine plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CommunityEngine'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
