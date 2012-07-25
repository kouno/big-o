require 'helpers/simulation'
require File.expand_path('../../lib/big-o.rb', __FILE__)
require File.expand_path('../../lib/big-o-matchers.rb', __FILE__)

RSpec.configure do |c|
  c.include BigO
  c.include BigO::Helpers
end