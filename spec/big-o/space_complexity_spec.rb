require 'spec_helper'
include BigO

describe SpaceComplexity do
  before :each do
    @space_complexity = SpaceComplexity.new
  end

  it 'should implement value_to_s' do
    @space_complexity.result_set = { 1 => 11_000,
                                     2 => 12_000,
                                     3 => 13_000 }
    @space_complexity.values_to_s.should =~ /\A\[([0-9]+, ){2}[0-9]+\]\z/
  end

  it 'should raise an exception if timeout is reached and no result was found' do
    @space_complexity.options[:timeout] = 0.001
    @space_complexity.options[:fn]      = lambda { |_| simulate_memory_space(1) }
    lambda { @space_complexity.process }.should raise_error(Timeout::Error)
  end

  it 'should ignore whatever is happening in a before/after hook' do
    @space_complexity.options[:fn] = lambda { |_| simulate_memory_space(1024) }
    @space_complexity.options[:before_hook] = lambda { |n| simulate_memory_space(1024 * n) }
    @space_complexity.options[:after_hook] = lambda { |n| simulate_memory_space(1024 * n) }
    @space_complexity.options[:approximation] = 0.2
    @space_complexity.should match_complexity_level 'O(1)', lambda { |_| 1 }
  end

  describe '#process on complexity O(1)' do
    before :each do
      @space_complexity.options[:fn] = lambda { |_| simulate_memory_space(1024) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @space_complexity.options[:approximation] = 0.2
      @space_complexity.should match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe '#process on complexity O(n)' do
    before :each do
      @space_complexity.options[:fn] = lambda { |n| simulate_memory_space(1024 * n) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @space_complexity.should match_complexity_level 'O(n)', lambda { |n| n }
    end

    it 'should return false if the complexity does not match (too low)' do
      @space_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe '#process on complexity O(n**2)' do
    before :each do
      @space_complexity.options[:fn] = lambda { |n| simulate_memory_space(1024 * n**2) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @space_complexity.should match_complexity_level 'O(n^2)', lambda { |n| n**2 }
    end

    it 'should return false if the complexity does not match (too low)' do
      @space_complexity.should_not match_complexity_level 'O(n)', lambda { |n| n }

      @space_complexity.options[:approximation] = 0.2
      @space_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end
end