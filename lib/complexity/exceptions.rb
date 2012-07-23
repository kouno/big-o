module Complexity
  # The function could not be run more than X times (where X is a configurable value).
  #
  # This exception happens if the function is too slow to run, or if the timeout is too short.
  class SmallResultSetError < StandardError
    # @param [Integer] resultset_size number of values the result set contains.
    def initialize(resultset_size)
      super "Less than #{resultset_size} values could be retrieved." +
          " Try using longer timeout or a different range. (function complexity may be too high)"
    end
  end

  # The function runs too fast and can't be quantified by our measurement tool.
  #
  # To fix this error, it is possible to augment the number of times the function should run.
  class InstantaneousExecutionError < StandardError
    def initialize
      super "Function execution time can't be quantified. (execution speed close to instantaneous)"
    end
  end
end