require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class FailureCatcher < BaseFormatter

        def failures_file_name
          num = ENV['TEST_ENV_NUMBER']
          num = 1 if num.nil? || num.empty?
          "rspec_#{num}.failures"
        end

        # create files called rspec_#.failures with a list of failed examples
        def dump_failures
          return if failed_examples.empty?
          f = File.new(failures_file_name, "w+")
          failed_examples.each do |example|
            f.puts retry_command(example)
          end
          f.close
        end

        def retry_command(example)
          example_name = example.full_description.gsub("\"", "\\\"")
          "-e \"#{example_name}\""
        end

      end
    end
  end
end