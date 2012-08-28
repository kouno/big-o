require 'spec_helper'
include BigO

describe 'match_complexity_level matcher' do
  before :each do
    @test_complexity = TimeComplexity.new({ :fn => lambda { |n| simulate_utime_processing(0.01 * n) } })
  end

  it "should not match O(1) for a constant augmentation" do
    @matcher = match_complexity_level('O(1)', lambda { |_| 1 })
    @matcher.matches?(@test_complexity).should be_false
  end

  it "should match O(n) for a constant augmentation" do
    @matcher = match_complexity_level('O(n)', lambda { |n| n })
    @matcher.matches?(@test_complexity).should be_true
  end

  context 'when using should' do
    before :each do
      @matcher = match_complexity_level('O(1)', lambda { |_| 1 })
    end

    it "should provide a descriptive error message" do
      @matcher.matches?(@test_complexity)
      @matcher.failure_message_for_should.should =~ /\Aexpected a complexity level of O\(1\)/
      @matcher.failure_message_for_should.should =~ /scale: [0-9.]+/
      @matcher.failure_message_for_should.should =~ /\[[0-9E., ]+\]+/
      @matcher.failure_message_for_should.should =~ /total values: [0-9]+ on 20/
    end
  end

  context 'when using should_not' do
    before :each do
      @matcher = match_complexity_level('O(n)', lambda { |n| n })
    end

    it "should provide a descriptive error message" do
      @matcher.matches?(@test_complexity)
      @matcher.failure_message_for_should_not.should =~ /\Aexpected a complexity level over O\(n\)/
      @matcher.failure_message_for_should_not.should =~ /scale: [0-9E.]+/
      @matcher.failure_message_for_should_not.should =~ /\[[0-9E., ]+\]+/
      @matcher.failure_message_for_should_not.should =~ /total values: [0-9]+ on 20/
    end
  end
end
