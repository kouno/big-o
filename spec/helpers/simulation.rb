module Helpers
  def simulate_utime_processing(seconds)
    Timeout::timeout(seconds) do
      while true; 1 ** 100 end
    end
  rescue Timeout::Error => e
    # mute error.
  end
end