namespace :spec do
  desc "Run all specs in the presence of ActiveSupport"
  RSpec::Core::RakeTask.new(:with_active_support)

  desc "Run all specs in the presence of the tzinfo gem"
  RSpec::Core::RakeTask.new(:with_tzinfo_gem)
  multiruby_path = `which multiruby`.chomp
  if multiruby_path.length > 0 && RSpec::Core::RakeTask.instance_methods.include?("ruby_cmd")
    namespace :multi do
      desc "Run all specs with multiruby and ActiveSupport"
      RSpec::Core::RakeTask.new(:with_active_support) do |t|
        t.ruby_cmd = "#{multiruby_path}"
        t.verbose = true
      end

      desc "Run all specs multiruby and the tzinfo gem"
      RSpec::Core::RakeTask.new(:with_tzinfo_gem) do |t|
        t.ruby_cmd = "#{multiruby_path}"
        t.verbose = true
      end
    end

    desc "run all specs under multiruby with ActiveSupport and also with the tzinfo gem"
    task :multi => [:"spec:multi:with_active_support", :"spec:multi:with_tzinfo_gem"]
  end
end

namespace :performance do
  desc 'Run all benchmarks'
  task :benchmark do
    bench_script = File.join(File.dirname(__FILE__), '..', '/script', 'benchmark_subject')
    bench_file = File.join(File.dirname(__FILE__), '..', '/performance_data', 'benchmarks.out')
    cat = ">"
    FileList[File.join(File.dirname(__FILE__), '..', '/performance', '*')].each do |f|
      cmd = "#{bench_script} #{File.basename(f)} #{cat} #{bench_file}"
      puts cmd
      `#{cmd}`
      cat = '>>'
    end
  end

  desc 'Run all profiles'
  task :profile do
    bench_script = File.join(File.dirname(__FILE__), '..', '/script', 'profile_subject')
    FileList[File.join(File.dirname(__FILE__), '..', '/performance', '*')].each do |f|
      cmd = "#{bench_script} #{File.basename(f)}"
      puts cmd
      `#{cmd}`
    end
  end
end
