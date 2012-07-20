module Complexity
  class TimeComplexity
    include ComplexityBase

    def measure(*args, &b)
      t0, r0 = Process.times, Time.now
      b.call(*args)
      t1, r1 = Process.times, Time.now
      tms = Benchmark::Tms.new(t1.utime  - t0.utime,
                               t1.stime  - t0.stime,
                               t1.cutime - t0.cutime,
                               t1.cstime - t0.cstime,
                               r1.to_f   - r0.to_f,
                               '')
      tms.utime
    end
  end
end