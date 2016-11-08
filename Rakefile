#!/usr/bin/env rake

#- 2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  RSpec::Core::RakeTask.new(:docs) do |t|
    t.rspec_opts = ["--format doc"]
  end
end

#task :default => :spec
task :default => [:"spec:with_tzinfo_gem", :"spec:with_active_support"]

Dir['tasks/**/*.rake'].each { |t| load t }
