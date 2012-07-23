module Complexity
  # Measure time complexity.
  class TimeComplexity
    include ComplexityBase

    # Raises the error percentage due to possible concurrency issue on the system (which in
    # certain cases may cause some measures to be far longer than others).
    def initialize(options = {})
      options = { :error_pct => 0.1 }.merge(options)
      super(options)
    end

    # Checks if the function can be measured and throw an error if it could not.
    def process
      @scale ||= get_scale
      raise InstantaneousExecutionError.new unless @scale > 0
      super
    end

    # Measures the execution time that <code>fn</code> is using.
    #
    # @param [Array] args arguments which the given block should take
    # @yield function which should be measured (fn)
    # @return [Float] measurement
    def measure(*args, &b)
      t0 = Process.times
      b.call(*args)
      t1 = Process.times
      t1.utime - t0.utime
    end
  end
end