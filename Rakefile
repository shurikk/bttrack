
require 'rake/testtask'
require 'rdoc/task'

task :default => :test

desc "Run all tests"
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test' << '.'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

desc "Generate RDoc"
Rake::RDocTask.new :doc do |rdoc|
  rdoc.rdoc_dir = 'doc'
end
