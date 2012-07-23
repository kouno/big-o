module Complexity
  class TimeComplexity
    include ComplexityBase

    def initialize
      @error_pct = 0.1
      super
    end

    def process
      @scale ||= get_scale
      raise InstantaneousExecutionError.new unless @scale > 0
      super
    end

    def measure(*args, &b)
      t0 = Process.times
      b.call(*args)
      t1 = Process.times
      t1.utime - t0.utime
    end
  end
end