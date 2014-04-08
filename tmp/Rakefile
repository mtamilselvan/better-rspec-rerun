require 'rspec/core/rake_task'
require 'rspec_junit_formatter'
require 'securerandom'

ALL_FAILURES = './all.failures'

def gather_failures
  opts = ""
  files = Dir.glob('*.failures')
  files.each { |file| opts << File.read(file).gsub(/\n/, ' ') }
  f = File.new(ALL_FAILURES, 'w+')
  f.write opts.rstrip
  f.close
end

def all_failures
  File.read(ALL_FAILURES)
end

def cleanup_failures
 `rm *.failures` unless Dir.glob('*.failures').empty?
end

def cleanup_xml
 `rm ./tmp/*.xml` unless Dir.glob('./tmp/*.xml').empty?
end

namespace :series do
  RSpec::Core::RakeTask.new('run') do |t|
    t.pattern = "spec/**_spec.rb"
    t.verbose = false
    t.fail_on_error = false
    t.rspec_opts = [
      "--require", "./failure_catcher.rb",
      "--format", "RSpec::Core::Formatters::FailureCatcher",
      "--format", "progress"
    ].flatten
  end

  RSpec::Core::RakeTask.new('retry') do |t|
    gather_failures
    puts "Retrying #{all_failures.split(/failed/).count - 1} failed tests!"
    t.pattern = "spec/**_spec.rb"
    t.verbose = false
    t.fail_on_error = false
    t.rspec_opts = [
      "-O", ALL_FAILURES,
      "--format", "progress"
    ].flatten
  end

  desc 'full'
  task "full" do
    cleanup_xml
    Rake::Task["series:run"].execute
    unless $?.success?
      Rake::Task["series:retry"].execute
    end
    cleanup_failures
  end
end

def uuid
  require 'securerandom'
  SecureRandom.uuid.delete('-')
end

namespace :parallel do
  desc "run"
  task :run do
    system("parallel_rspec -n 5 \
      --test-options '--require ./failure_catcher.rb \
      --format RSpec::Core::Formatters::FailureCatcher' spec")
  end

  desc "retry"
  task :retry do
    gather_failures
    failed_tests = all_failures
    puts "Retrying #{failed_tests.split(/failed/).count - 1} failed tests!"
    system("parallel_rspec -n 5 --test-options '#{failed_tests}' spec")
  end

  desc "full"
  task :full do
    cleanup_xml
    Rake::Task["parallel:run"].execute
    unless $?.success?
      Rake::Task["parallel:retry"].execute
    end
    cleanup_failures
  end

end
