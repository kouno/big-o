require 'spec_helper'
include BigO

describe TimeComplexity do
  before :each do
    @time_complexity = TimeComplexity.new
  end

  MIN_TIME = 0.01
  AVG_TIME = 0.02

  it 'should raise an exception if timeout is reached and no result was found' do
    @time_complexity.options[:timeout] = 0.001
    @time_complexity.options[:fn]      = proc { simulate_utime_processing(1) }
    lambda { @time_complexity.process }.should raise_error(Timeout::Error)
  end

  it 'should ignore whatever is happening in a before/after hook' do
    @time_complexity.options[:fn] = lambda { |_| simulate_utime_processing(MIN_TIME) }
    @time_complexity.options[:before_hook] = lambda { |n| simulate_utime_processing(MIN_TIME * n) }
    @time_complexity.options[:after_hook] = lambda { |n| simulate_utime_processing(MIN_TIME * n) }
    @time_complexity.options[:approximation] = 0.2
    @time_complexity.should match_complexity_level 'O(1)', lambda { |_| 1 }
  end


  describe '#process on complexity O(1)' do
    before :each do
      @time_complexity.options[:fn] = lambda { |_| simulate_utime_processing(AVG_TIME) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @time_complexity.options[:approximation] = 0.2
      @time_complexity.should match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe '#process on complexity O(n)' do
    before :each do
      @time_complexity.options[:fn] = lambda { |n| simulate_utime_processing(AVG_TIME * n) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @time_complexity.should match_complexity_level 'O(n)', lambda { |n| n }
    end
  end

  describe '#process on complexity O(n**2)' do
    before :each do
      @time_complexity.options[:minimum_result_set_size] = 0
      @time_complexity.options[:fn] = lambda { |n| simulate_utime_processing(AVG_TIME * (n**2)) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @time_complexity.should match_complexity_level 'O(n^2)', lambda { |n| n**2 }
    end

    it 'should return false if the complexity does not match (too low)' do
      @time_complexity.options[:approximation] = 0.2
      @time_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe 'very small execution time functions (0.01 second and below)' do
    it 'should still be valid in case of O(n**2)' do
      @time_complexity.options[:fn] = lambda { |n| simulate_utime_processing(MIN_TIME * n**2) }
      @time_complexity.should     match_complexity_level 'O(n**2)',     lambda { |n| n**2 }
      @time_complexity.should_not match_complexity_level 'O(n log(n))', lambda { |n| n * Math::log(n) }
      @time_complexity.should_not match_complexity_level 'O(1)',        lambda { |_| 1 }
    end

    it 'should still be valid in case of O(n)' do
      @time_complexity.options[:fn] = lambda { |n| simulate_utime_processing(MIN_TIME * n) }
      @time_complexity.should     match_complexity_level 'O(n)', lambda { |n| n }
      @time_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end

    it 'should still be valid for execution time close to ~0.001 second' do
      @time_complexity.options[:fn]    = lambda { |n| simulate_utime_processing(BigDecimal.new('0.001') * n) }
      @time_complexity.should     match_complexity_level 'O(n)', lambda { |n| n }
      @time_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end

    it 'should throw an error if execution time is not measurable for n = 1 (execution time under ~0.001 second)' do
      # no calculation, execution time should be instant.
      @time_complexity.options[:fn] = lambda { |_| 1 }
      lambda { @time_complexity.process }.should raise_error(InstantaneousExecutionError)
    end
  end
end