module BigO
  # Measure space complexity.
  class SpaceComplexity
    include ComplexityBase
    # Measures the memory space that <code>fn</code> is using.
    #
    # @yield function which should be measured (fn), uses args
    # @return [Numeric] measurement
    def measure(*args, &b)
      @memory_measures = []

      GC.disable

      pid = fork_and_run(*args, &b)
      watch_fork_memory(pid)
      Process.wait

      GC.enable

      fork_memory_usage
    end

    # Creates fork which will run the given block.
    #
    # @yield [*args] function which needs to be measured
    # @return [Integer] pid
    def fork_and_run(*args, &b)
      Process.fork do
        @memory_measures << memory_measure(Process.pid)
        b.call(*args)
        @memory_measures << memory_measure(Process.pid)
        exit
      end
    end

    # Gets fork's memory usage.
    #
    # @return [Numeric] memory usage
    def fork_memory_usage
      if @memory_measures.size > 2
        @memory_measures.max - @memory_measures.min
      else
        0
      end
    end

    # Takes memory measurements of the given process.
    #
    # @param [Integer] pid process id
    # @return [void]
    def watch_fork_memory(pid)
      while (memory_indicator = memory_measure(pid))
        break if memory_indicator == 0
        @memory_measures << memory_indicator
      end
    end

    # Measures current memory usage of given process.
    #
    # @param [Integer] pid process id
    # @return [Integer] memory usage
    def memory_measure(pid)
      `ps -o rss= -p #{pid}`.to_i
    end

    # @see ComplexityBase#values_to_s
    def values_to_s
      @result_set.values.to_s
    end
  end
end