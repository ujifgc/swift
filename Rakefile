ENV['RACK_ENV'] = 'test'

require File.expand_path('../config/boot.rb', __FILE__)
require 'padrino-core/cli/rake'
require 'awesome_print'
require 'rake/testtask'

PadrinoTasks.init

task :default => :test

Rake::TestTask.new :test do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end
