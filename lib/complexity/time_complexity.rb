module Complexity
  class TimeComplexity
    attr_accessor :level
    attr_accessor :fn
    attr_accessor :timeout
    attr_accessor :range
    attr_accessor :result
    attr_accessor :minimum_resultset_size

    def initialize
      @level                  = lambda { |n| n }
      @fn                     = proc { simulate_utime_processing(0.01) }
      @timeout                = 10
      @range                  = 1..10_000
      @result                 = nil
      @minimum_resultset_size = 10
    end

    def process
      real_complexity, expected_complexity = run_simulation
      examine_result_set(real_complexity, expected_complexity)
    end

    def run_simulation
      real_complexity     = {}
      expected_complexity = {}

      begin
        Timeout::timeout(@timeout) do
          @range.each do |n|
            next if (time_spent = measure(n, &@fn).utime) == 0
            real_complexity[n]     = time_spent
            expected_complexity[n] = @level.call(n)
          end
        end
      rescue Timeout::Error => e
        if real_complexity.empty? || expected_complexity.empty?
          raise e
        end
      end

      [real_complexity, expected_complexity]
    end

    def examine_result_set(real_complexity, expected_complexity)
      smallest_x, smallest_time   = real_complexity.first
      smallest_x, smallest_expect = expected_complexity.first

      time_unit = smallest_time / smallest_expect

      expected_complexity.each do |n, level|
        estimated_time_spent  = time_unit * level
        estimated_time_spent += estimated_time_spent * 0.05
        if real_complexity[n] > estimated_time_spent
          @result = false
          break
        end
      end

      @result = true if @result.nil?
      @result
    end

    def measure(*args, &b)
      t0, r0 = Process.times, Time.now
      b.call(*args)
      t1, r1 = Process.times, Time.now
      Benchmark::Tms.new(t1.utime  - t0.utime,
                         t1.stime  - t0.stime,
                         t1.cutime - t0.cutime,
                         t1.cstime - t0.cstime,
                         r1.to_f - r0.to_f,
                         '')
    end
  end
end