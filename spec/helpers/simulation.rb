module Helpers
  ONE_KILO_OCTET = 'a' * 1024

  def simulate_utime_processing(seconds)
    Timeout::timeout(seconds) do
      while true; 1 ** 100 end
    end
  rescue Timeout::Error => e
    # mute error.
  end

  def simulate_memory_space(ko)
    space = ONE_KILO_OCTET * ko
    sleep(0.01)
    space
  end
end