module Complexity
  # Measure space complexity.
  class SpaceComplexity
    include ComplexityBase

    # Measures the memory space that <code>fn</code> is using.
    #
    # @param [Array] args arguments which the given block should take
    # @yield function which should be measured (fn)
    # @return [Float] measurement
    def measure(*args, &b)
      memory_measures = []
      GC.disable

      pid = Process.fork do
        memory_measures << `ps -o rss= -p #{Process.pid}`.to_i
        b.call(*args)
        memory_measures << `ps -o rss= -p #{Process.pid}`.to_i
        exit
      end

      while (memory_indicator = `ps -o rss= -p #{pid}`.to_i)
        break if memory_indicator == 0
        memory_measures << memory_indicator
      end

      Process.wait

      GC.enable

      if memory_measures.size > 2
        memory_measures.max - memory_measures.min
      else
        0
      end
    end
  end
end