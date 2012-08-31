# Big-O [![Build Status](https://secure.travis-ci.org/Kouno/big-o.png?branch=master)](http://travis-ci.org/Kouno/big-o)

Big-O is a gem which analyses an anonymous function and verifies that it follows a specific pattern
in its memory usage or its execution time.

## Requirements

This gem has been tested on Mac OS X, using Ruby 1.9.3/1.9.2.

## Install

Installation is made through RubyGem:

```
gem install big-o
```

## Usage

### Directly in your code

Checking if a function has a complexity of O(n) is as simple as this:

```ruby
require 'big-o'

time_complexity = BigO::TimeComplexity({
  :fn    => lambda { |n| do_something_time_consuming(n) },
  :level => lambda { |n| n }
})
time_complexity.process # => true if it is growing in time constantly.
```

It is also possible to define multiple configuration parameters:

```ruby
require 'big-o'

time_complexity = BigO::SpaceComplexity({
  :fn => lambda { |n| do_something_time_consuming(n) }
  :level => lambda { |n| n },
  :range => 1..20,                # value of n
  :timeout => 10,                 # time in seconds
  :approximation => 0.05,         # percentage
  :error_pct => 0.05,             # percentage
  :minimum_result_set_size => 3,  # minimum results
  :after_hook => proc { },        # See before/after hooks
  :before_hook => proc { }
})
```

### RSpec Matchers

If you are using RSpec, there is a matcher already defined for matching a complexity level:

```ruby
require 'big-o'
require 'big-o-matchers'

describe 'do_something_time_consuming' do
  before :each do
    @time_complexity = BigO::TimeComplexity({
      :fn => lambda { |n| do_something_time_consuming(n) }
    })
  end

  it 'should have a complexity of O(n)' do
    @time_complexity.should match_complexity_level 'O(n)', lambda { |n| n }
  end

  it 'should not have a complexity of O(1)' do
    @time_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
  end
end
```

The string used as the first parameter (e.g. `'O(n)'`) is used to describe the lambda given as the
second parameter.

### After/Before hooks

Your function depends on something which needs to run before every call of your function? You need to
cleanup whatever dirty work your function performed? These operation are time consuming and they will
affect the values of your function? Well, just throw these things in the before/after hooks!

```ruby
time_complexity = BigO::TimeComplexity({
  :fn    => lambda { |_| whatever_action_which_doesnt_depend_on_n },
  :level => lambda { |n| n**2 },
  :before_hook => lambda { |n| prepare_fn_environment(n) },
  :after_hook => lambda { |n| clean_up(n) }
})
time_complexity.process # will only time :fn
```

Warning: The timeout is still in effect during before and after hooks execution (in our example, it may stop
during clean_up). There should not be any sensitive code which needs to be executed in before/after hooks.

If you need to cleanup something after `time_complexity.process`, you will prefer to place this code out of :after_hook 
or :before_hook.

## Change Log

* SpaceComplexity has been removed. (> 0.1)

## Reference

You may want to read more on the subject by reading:
* http://en.wikipedia.org/wiki/Analysis_of_algorithms
* http://en.wikipedia.org/wiki/Big_O_notation

## License

Complexity is licensed under the MIT License - see the LICENSE file for details
