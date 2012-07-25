require 'spec_helper'
include BigO

describe ComplexityBase do
  before :all do
    class FunctionComplexity
      include ComplexityBase

      def measure
        1
      end
    end
  end

  context 'with default values' do
    before :each do
      @fn_complexity = FunctionComplexity.new
    end

    it 'should have a timeout of 10 seconds' do
      @fn_complexity.options[:timeout].should == 10
    end

    it 'should have no result defined' do
      @fn_complexity.result.should be_nil
    end

    it 'should have an approximation of 5%' do
      @fn_complexity.options[:approximation].should == 0.05
    end

    it 'should refuse to process less than 4 values when processing a function' do
      real_complexity     = {}
      expected_complexity = {}
      3.times do |i|
        real_complexity[i]     = i
        expected_complexity[i] = i
      end

      @fn_complexity.scale = 1
      lambda {
        @fn_complexity.examine_result_set(real_complexity, expected_complexity)
      }.should raise_error(SmallResultSetError)
    end
  end

  context 'with overwritten values' do
    before :each do
      @fn_complexity = FunctionComplexity.new({ :timeout => 1,
                                                :approximation => 0.1 })
    end

    it 'should have the configured values' do
      @fn_complexity.options[:timeout].should == 1
      @fn_complexity.options[:approximation].should == 0.1
    end
  end
end