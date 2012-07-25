# Big-O

Big-O is a gem which analyse an anonymous function and verify that it follow a specific pattern
in its memory usage or its execution time.

## Requirements

Calculation of memory space is done via `ps`, and therefore, doesn't work on Windows.

This gem has been tested on Mac OS X, using Ruby 1.9.3.

## Usage

Checking if a function has a complexity of O(n) is as simple as this:

```ruby
time_complexity = BigO::TimeComplexity({
  :fn    => lambda { |n| do_something_time_consuming(n) },
  :level => lambda { |n| n }
})
time_complexity.process # => true if it is growing in time constantly.
```

It is also possible to define multiple configuration parameters:

```ruby
space_complexity = BigO::SpaceComplexity({
  :fn => lambda { |n| do_something_space_consuming(n) }
  :level => lambda { |n| n },
  :range => 1..20,                # value of n
  :timeout => 10,                 # time in seconds
  :approximation => 0.05,         # percentage
  :error_pct => 0.05,             # percentage
  :minimum_result_set_size => 3   # minimum results
})
```

## Reference

You may want to read more on the subject by reading:
* http://en.wikipedia.org/wiki/Analysis_of_algorithms
* http://en.wikipedia.org/wiki/Big_O_notation

## License

Complexity is licensed under the MIT License - see the LICENSE file for details