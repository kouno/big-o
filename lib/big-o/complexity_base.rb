module BigO
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
    # @option options [Proc] :fn function which will be measured [required]
    # @option options [Proc] :level complexity of the function [required]
    # @option options [Range] :range (1..20) values of `n` for which it will run the function
    # @option options [Numeric] :timeout (10) time (in seconds) after which the simulation will stop running
    # @option options [Float] :approximation (0.05) percentage by which we approximate our expected results
    # @option options [Float] :error_pct (0.05) percentage of times where we allow errors due to concurrent processing
    # @option options [Integer] :minimum_result_set_size (3) minimum number of results we need to have consistent data
    # @option options [Proc] :after_hook (proc {})
    # @option options [Proc] :before_hook (proc {})
    # @return [void]
    def initialize(options = {})
      @options = { :range => 1..20,
                   :timeout => 10,
                   :approximation => 0.05,
                   :error_pct => 0.05,
                   :minimum_result_set_size => 3,
                   :before_hook => proc {},
                   :after_hook => proc {} }

      @options.merge!(options)
      @result_set = {}
    end

    # Benchmarks the given function (<code>@fn</code>) and tells if it follows the given pattern
    # (<code>@options[:level]</code>).
    #
    # @return [Boolean]
    def process
      @scale ||= get_scale
      run_simulation
      @result = examine_result_set
    end

    # Runs simulation.
    #
    # A simulation can fail to execute every element in <code>range</code> because it exceeded the timeout limit.
    # If no result was returned in the `timeout` time frame, this method will generate an exception.
    #
    # @return [void]
    # @raise [Timeout::Error]
    def run_simulation
      Timeout::timeout(@options[:timeout]) do
        @options[:range].each do |n|
          next if (measure = measurement(n)) <= 0
          @result_set[n] = measure
        end
      end
    rescue Timeout::Error => e
      if @result_set.empty?
        raise e
      end
    end

    # Measurement process.
    #
    # Composed of the measurement itself and executing two hooks :before_hook and :after_hook.
    # Due to the structure of the measurement, the hooks are not (and should not) be part of the
    # measure. In other words, any code executed within :before_hook or :after_hook will not affect
    # the time/space measure of :fn.
    #
    # @param [Integer] n iteration
    # @return [Float] indicator
    def measurement(n)
      @options[:before_hook].call(n)
      measure = measure(n, &@options[:fn])
      @options[:after_hook].call(n)
      measure
    end

    # Parses data from <code>#run_simulation</code>.
    #
    # <code>examine_result_set</code> will return true only if these conditions are met:
    # - expected complexity is never exceeded. Some inconsistencies may however be allowed
    #   (see <code>@options[:error_pct]</code>).
    #
    # @return [Boolean]
    # @raise [SmallResultSetError]
    def examine_result_set
      if small_result_set?
        raise SmallResultSetError.new(@options[:minimum_result_set_size])
      end

      @result_set.each do |n, measure|
        next if n == 1 # scale was taken from n == 1, no need to compare this value
        if maximum_complexity(n) <= measure
          if allow_inconsistency?
            next
          else
            return false
          end
        end
      end

      true
    end

    # Maximum complexity depending on n.
    #
    # For O(n**2), if n == 5 the "maximum complexity" would be 25.
    # including an approximation of 5%, it would be 25 + 1.25.
    #
    # @param [Integer] n
    # @return [Float] maximum complexity
    def maximum_complexity(n)
      estimated_complexity = @scale * @options[:level].call(n)
      estimated_complexity + (estimated_complexity * @options[:approximation])
    end

    # Should an inconsistency be allowed considering the size of the result set?
    #
    # @return [Boolean]
    def allow_inconsistency?
      @allowed_inconsistencies ||= (@result_set.size * @options[:error_pct]).floor
      if @allowed_inconsistencies > 0
        @allowed_inconsistencies -= 1
        true
      else
        false
      end
    end

    # Does the result set contain less than the required number of element ?
    #
    # @return [Boolean]
    def small_result_set?
      @result_set.size <= @options[:minimum_result_set_size]
    end

    # Finds what is the first measure of our function. (n == 1)
    #
    # @return [Numeric]
    def get_scale
      runs = []
      10.times do
        runs << measure(1, &@options[:fn])
      end
      runs.inject(:+) / 10
    end

    # Measures the given block.
    #
    # This method should be re-implemented on any class which includes ComplexityBase.
    #
    # @yield [*args] function which needs to be measured
    # @return [Numeric] measurement
    def measure(*args, &b)
    end

    # Creates a descriptive string of the calculated complexity.
    #
    # @see Object#to_s
    def to_s
      "values: #{values_to_s} scale: #@scale total values: #{@result_set.size} on #{@options[:range].max}"
    end

    # Converts result set to a string.
    #
    # @return [String]
    def values_to_s
    end
  end
end