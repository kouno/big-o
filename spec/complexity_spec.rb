require_relative '../lib/complexity.rb'
include Complexity

describe TimeComplexity do
  before :each do
    @complexity = TimeComplexity.new
  end

  it 'should have a default timeout of 30 seconds' do
    @complexity.timeout.should == 10
  end

  it 'should raise an exception if timeout is reached and no result was found' do
    @complexity.timeout = 0.001
    @complexity.fn      = proc { simulate_utime_processing(1) }
    lambda { @complexity.process }.should raise_error(Timeout::Error)
  end

  describe '#process on complexity O(1)' do
    before :each do
      @complexity.level = lambda { |n| 1 }
      @complexity.fn    = lambda { |n| simulate_utime_processing(0.0001) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      lambda { @complexity.process }.should_not raise_error
      @complexity.result.should be_true
    end
  end

  describe '#process on complexity O(n)' do
    before :each do
      @complexity.level = lambda { |n| n }
      @complexity.fn    = lambda { |n| simulate_utime_processing(0.0001 * n) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      lambda { @complexity.process }.should_not raise_error
      @complexity.result.should be_true
    end
  end

  describe '#process on complexity O(n**2)' do
    before :each do
      @complexity.level = lambda { |n| n**2 }
      @complexity.fn    = lambda { |n| simulate_utime_processing(0.0001 * (n**2)) }
      @complexity.range = 1..1_000
    end

    it 'should run the function and produce a report when time threshold is hit' do
      lambda { @complexity.process }.should_not raise_error
      @complexity.result.should be_true
    end

    it 'should return false if the complexity doesn\'t match (too low)' do
      @complexity.level = lambda { |n| 1 }
      lambda { @complexity.process }.should_not raise_error
      @complexity.result.should be_false
    end
  end
end