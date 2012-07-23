module Complexity
  class SmallResultSetError < StandardError
    def initialize(resultset_size)
      super "Less than #{resultset_size} values could be retrieved." +
          " Try using longer timeout or a different range. (function complexity may be too high)"
    end
  end

  class InstantaneousExecutionError < StandardError
    def initialize
      super "Function execution time can't be quantified. (execution speed close to instantaneous)"
    end
  end
end