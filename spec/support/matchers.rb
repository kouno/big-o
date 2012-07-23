RSpec::Matchers.define :match_complexity_level do |o_notation, complexity_level|
  match do |complexity|
    complexity.options[:level] = complexity_level
    complexity.process
  end

  failure_message_for_should do |complexity|
    # since we are playing around with floating values,
    # sorting the result_set helps minimising issues with addition of floats
    result_set = complexity.result_set.sort
    total = result_set.inject(0) { |sum, r| sum + r[1] }.to_f
    "expected a complexity level of #{o_notation}, " +
        "got scale: #{complexity.scale} min: #{result_set[0][1]} " +
        "max: #{result_set[-1][1]} " +
        "avg: #{total / result_set.size} " +
        "total values: #{result_set.size} on #{complexity.range}"
  end

  failure_message_for_should_not do |complexity|
    result_set = complexity.result_set.sort
    total = result_set.inject(0) { |sum, r| sum + r[1] }.to_f
    "expected a complexity level over #{o_notation}, " +
        "got scale: #{complexity.scale} min: #{result_set[0][1]} " +
        "max: #{result_set[-1][1]} " +
        "avg: #{total / result_set.size} " +
        "total values: #{result_set.size} on #{complexity.range}"
  end

  description do
    "should match complexity level #{o_notation}"
  end
end