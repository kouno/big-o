module BigO
  PID = Process.pid
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/coverage/'
  add_filter '/doc/'
end

SimpleCov.at_exit do
  # Ignore forks and create coverage files only when the main process exits
  SimpleCov.result.format! if Process.pid == BigO::PID
end