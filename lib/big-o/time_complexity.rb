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

    # Gets scale.
    #
    # Implement tolerance for fast executing functions. Any function executing in less than
    # 0.01 second will be scaled up by a factor of 10.
    #
    # @see ComplexityBase#get_scale
    def get_scale
      scale = super
      while scale < BigDecimal.new('0.01')
        increase_scale
        scale = super
      end

      scale
    end

    # Increases scale.
    #
    # @return [void]
    def increase_scale
      raise InstantaneousExecutionError.new if @scale_increased_count >= @options[:scale_increase_limit]
      @scale_increased_count += 1
    end

    # @see ComplexityBase#values_to_s
    def values_to_s
      @result_set.values.map(&:to_f).inspect
    end
  end
end