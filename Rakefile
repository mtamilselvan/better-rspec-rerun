require 'rspec/core/rake_task'
require 'rspec_junit_formatter'

def gather_failures
  opts = ""
  files = Dir.glob('*.failures')
  files.each { |file| opts << File.read(file).gsub(/\n/, ' ') }
  all_failures = './all.failures'
  File.write(all_failures, opts.rstrip)
  return File.read all_failures
end

def cleanup(files = '')
  system("rm #{files}") unless Dir.glob("#{files}").empty?
end

def launch(params = {})
  if params[:test_options].include? '-e'
    puts "Retrying #{params[:test_options].split(/failed/).count - 1} failed tests!"
  end
  system("parallel_rspec -n #{params[:processes] || 5} --test-options '#{params[:test_options]}' spec")
end

def run(processes = 5)
  launch(processes: processes, test_options: '--require ./failure_catcher.rb \
   --format RSpec::Core::Formatters::FailureCatcher')
end

def rerun(processes = 5)
  launch(processes: processes, test_options: gather_failures)
end

desc "parallel test execution with failure retries"
task :parallel, :processes do |t, args|
  cleanup 'results/*.xml'
  run args[:processes]
  unless $?.success?
    rerun args[:processes]
  end
  cleanup '*.failures'
end

#namespace :series do
#  RSpec::Core::RakeTask.new('run') do |t|
#    t.pattern = "spec/**_spec.rb"
#    t.verbose = false
#    t.fail_on_error = false
#    t.rspec_opts = [
#      "--require", "./failure_catcher.rb",
#      "--format", "RSpec::Core::Formatters::FailureCatcher",
#      "--format", "progress"
#    ].flatten
#  end
#
#  RSpec::Core::RakeTask.new('retry') do |t|
#    failed_tests = gather_failures
#    puts "Retrying #{failed_tests.split(/failed/).count - 1} failed tests!"
#    t.pattern = "spec/**_spec.rb"
#    t.verbose = false
#    t.fail_on_error = false
#    t.rspec_opts = [
#      "-O", './all.failures',
#      "--format", "progress"
#    ].flatten
#  end
#
#  desc 'full'
#  task "full" do
#    cleanup '.xml'
#    Rake::Task["series:run"].execute
#    unless $?.success?
#      Rake::Task["series:retry"].execute
#    end
#    cleanup '.failures'
#  end
#end
