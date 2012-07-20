module Complexity
  module ComplexityBase
    attr_accessor :level
    attr_accessor :fn
    attr_accessor :timeout
    attr_accessor :range
    attr_accessor :result
    attr_accessor :minimum_result_set_size
    attr_accessor :result_set
    attr_accessor :approximation
    attr_accessor :scale

    def initialize
      @timeout                 = 10
      @range                   = 1..20
      @result                  = nil
      @minimum_result_set_size = 4
      @approximation           = 0.05
    end

    def process
      @scale ||= get_scale
      examine_result_set(*run_simulation)
    end

    def run_simulation
      real_complexity     = {}
      expected_complexity = {}

      begin
        Timeout::timeout(@timeout) do
          @range.each do |n|
            next if (indicator = measure(n, &@fn)) == 0
            real_complexity[n]     = indicator
            expected_complexity[n] = @level.call(n)
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
      if real_complexity.size < @minimum_result_set_size
        raise SmallResultSetError.new(@minimum_result_set_size)
      end

      expected_complexity.each do |n, level|
        estimated_complexity  = @scale * level
        estimated_complexity += estimated_complexity * @approximation
        if real_complexity[n] > estimated_complexity
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
        runs << measure(1, &@fn)
      end
      runs.inject(:+) / runs.size
    end
  end
end