require 'helpers/simulation'
require File.expand_path('../../lib/complexity.rb', __FILE__)
require File.expand_path('../../lib/complexity-matchers.rb', __FILE__)

RSpec.configure do |c|
  c.include Helpers
  c.include Complexity
end