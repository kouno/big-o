RSpec::Matchers.define :match_complexity_level do |o_notation, complexity_level|
  match do |complexity|
    complexity.options[:level] = complexity_level
    complexity.process
  end

  failure_message_for_should do |complexity|
    "expected a complexity level of #{o_notation}, got (#{complexity.to_s})"
  end

  failure_message_for_should_not do |complexity|
    "expected a complexity level over #{o_notation}, got (#{complexity.to_s})"
  end
end