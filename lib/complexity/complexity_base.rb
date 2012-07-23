module Complexity
  module ComplexityBase
    attr_accessor :fn
    attr_accessor :result
    attr_accessor :result_set
    attr_accessor :scale
    attr_accessor :options

    def initialize(options = {})
      @options = { :range => 1..20,
                   :timeout => 10,
                   :approximation => 0.05,
                   :error_pct => 0.05,
                   :minimum_result_set_size => 4 }

      @options.merge!(options)
    end

    def process
      @scale ||= get_scale
      examine_result_set(*run_simulation)
    end

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

    def examine_result_set(real_complexity, expected_complexity)
      if real_complexity.size < @options[:minimum_result_set_size]
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

    def get_scale
      runs = []
      10.times do
        runs << measure(1, &@options[:fn])
      end
      runs.inject(:+) / 10
    end
  end
end