require "bundler"
require 'rake/testtask'

Bundler.setup
Bundler.require(:test)


Rake::TestTask.new do |t|
  t.libs.push "lib", "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end