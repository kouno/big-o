module BigO
  module Helpers
    ONE_KILO_OCTET = 'a' * 1024

    def simulate_utime_processing(seconds)
      t0 = Process.times
      begin
        t1 = Process.times
      end while (BigDecimal.new(t1.utime.to_s) - BigDecimal.new(t0.utime.to_s)) < BigDecimal.new(seconds.to_s)
    end

    def simulate_memory_space(ko)
      space = ONE_KILO_OCTET * ko
      sleep(0.01)
      space
    end
  end
end