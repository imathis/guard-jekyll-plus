require 'bundler/gem_tasks'
require 'nenv'

require 'rspec/core/rake_task'
rspec = RSpec::Core::RakeTask.new do |t|
  t.verbose = Nenv.ci?
end

task default: rspec.name
