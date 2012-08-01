require 'bigdecimal'

module BigO
  # Measure time complexity.
  class TimeComplexity
    include ComplexityBase
    # Raises the error percentage due to possible concurrency issue on the system (which in
    # certain cases may cause some measures to be far longer than others).
    #
    # @see ComplexityBase#initialize
    def initialize(options = {})
      tc_options = { :error_pct => 0.1,
                     :scale_increase_limit => 5 }
      @scale_increased_count = 0
      super(tc_options.merge(options))
    end

    # Checks if the function can be measured and throw an error if it could not.
    #
    # @see ComplexityBase#process
    def process
      @scale ||= get_scale
      raise InstantaneousExecutionError.new unless @scale > 0
      super
    end

    # Measures the execution time that <code>fn</code> is using.
    #
    # @see ComplexityBase#measure
    def measure(*args, &b)
      t0 = Process.times
      (10 ** @scale_increased_count).times do
        b.call(*args)
      end
      t1 = Process.times
      BigDecimal.new(t1.utime.to_s) - BigDecimal.new(t0.utime.to_s)
    end

    def get_scale
      scale = super
      while scale < BigDecimal.new('0.1')
        increase_scale
        scale = super
      end

      scale
    end

    def increase_scale
      raise InstantaneousExecutionError.new if @scale_increased_count >= @options[:scale_increase_limit]
      @scale_increased_count += 1
    end
  end
end