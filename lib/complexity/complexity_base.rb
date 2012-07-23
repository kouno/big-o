module Complexity
  # ComplexityBase regroup every process common to the benchmarking of a function.
  module ComplexityBase

    # @return [Boolean] Result from measurement
    attr_accessor :result

    # @return [Hash] Contains the whole benchmark
    attr_accessor :result_set

    # @return [Float] Element on which the whole benchmark is based (for <code>n = 1</code>)
    attr_accessor :scale

    # @return [Hash] Contains the different configurable options
    attr_accessor :options

    # Configures default values.
    #
    # @param [Hash] options the options necessary to benchmark the given lambda. Any of these options
    #               can be defined just before running a simulation using <code>options</code>.
    #
    #     {
    #        :fn => lambda { |n| do_something(n) }  # function which will be measured [required]
    #        :level => lambda { |n| n }             # complexity of the function [required]
    #        :range => 1..20,                       # values of `n` for which it will run the function
    #        :timeout => 10,                        # time (in seconds) after which the simulation will stop running
    #        :approximation => 0.05,                # percentage by which we approximate our expected results
    #        :error_pct => 0.05,                    # percentage of times where we allow errors due to concurrent processing
    #        :minimum_result_set_size => 3          # minimum number of results we need to have consistent data
    #      }
    # @return [void]
    def initialize(options = {})
      @options = { :range => 1..20,
                   :timeout => 10,
                   :approximation => 0.05,
                   :error_pct => 0.05,
                   :minimum_result_set_size => 3 }

      @options.merge!(options)
    end

    # Benchmarks the given function (<code>@fn</code>) and tells if it follows the given pattern
    # (<code>@options[:level]</code>).
    #
    # @return [Boolean]
    def process
      @scale ||= get_scale
      examine_result_set(*run_simulation)
    end

    # Runs simulation.
    #
    # A simulation can fail to execute every element in <code>range</code> because it exceeded the timeout limit. If no result
    # was returned in the `timeout` time frame, this method will generate an exception.
    #
    # @return [Array] contains an array (first element) of values which are the measurement of the function
    #                 and another array (second element) of values which are the expected values for the first one.
    # @raise [Timeout::Error]
    def run_simulation
      real_complexity     = {}
      expected_complexity = {}

      begin
        Timeout::timeout(@options[:timeout]) do
          @options[:range].each do |n|
            next if (indicator = measure(n, &@options[:fn])) == 0
            real_complexity[n]     = indicator
            expected_complexity[n] = @options[:level].call(n)
          end
        end
      rescue Timeout::Error => e
        if real_complexity.empty? || expected_complexity.empty?
          raise e
        end
      end

      @result_set = real_complexity
      [real_complexity, expected_complexity]
    end

    # Parses data from <code>#run_simulation</code>.
    #
    # <code>examine_result_set</code> will return true only if these conditions are met:
    # - expected complexity is never exceeded. Some inconsistencies may however be allowed
    #   (see <code>@options[:error_pct]</code>).
    # - there is a minimum of X results in real_complexity, where X is <code>@options[:minimum_result_set_size]</code>.
    #   if this condition is not met, an exception will be thrown.
    #
    # @param [Array] real_complexity
    # @param [Array] expected_complexity
    # @return [Boolean]
    # @raise [SmallResultSetError]
    def examine_result_set(real_complexity, expected_complexity)
      if real_complexity.size <= @options[:minimum_result_set_size]
        raise SmallResultSetError.new(@options[:minimum_result_set_size])
      end

      allowed_inconsistencies = (expected_complexity.size * @options[:error_pct]).floor
      expected_complexity.each do |n, level|
        next if n == 1
        estimated_complexity  = @scale * level
        estimated_complexity += estimated_complexity * @options[:approximation]
        if estimated_complexity <= real_complexity[n]
          if allowed_inconsistencies > 0
            allowed_inconsistencies -= 1
            next
          end
          @result = false
          break
        end
      end

      @result = true if @result.nil?
      @result
    end

    # Finds what is the first measure of our function.
    #
    # @return [Float]
    def get_scale
      runs = []
      10.times do
        runs << measure(1, &@options[:fn])
      end
      runs.inject(:+) / 10
    end
  end
end