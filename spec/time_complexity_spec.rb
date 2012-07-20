require 'spec_helper'
include Complexity

describe TimeComplexity do
  before :each do
    @time_complexity = TimeComplexity.new
  end

  it 'should raise an exception if timeout is reached and no result was found' do
    @time_complexity.timeout = 0.001
    @time_complexity.fn      = proc { simulate_utime_processing(1) }
    lambda { @time_complexity.process }.should raise_error(Timeout::Error)
  end

  describe '#process on complexity O(1)' do
    before :each do
      @time_complexity.fn    = lambda { |_| simulate_utime_processing(0.5) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @time_complexity.approximation = 0.2
      @time_complexity.should match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe '#process on complexity O(n)' do
    before :each do
      @time_complexity.fn    = lambda { |n| simulate_utime_processing(0.5 * n) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @time_complexity.should match_complexity_level 'O(n)', lambda { |n| n }
    end
  end

  describe '#process on complexity O(n**2)' do
    before :each do
      @time_complexity.minimum_result_set_size = 0
      @time_complexity.fn = lambda { |n| simulate_utime_processing(0.5 * (n**2)) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @time_complexity.should match_complexity_level 'O(n^2)', lambda { |n| n**2 }
    end

    it 'should return false if the complexity does not match (too low)' do
      @time_complexity.approximation = 0.2
      @time_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end
end