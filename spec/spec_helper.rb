require 'helpers/simulation'
Dir["./spec/support/**/*.rb"].each {|f| require f}
require File.expand_path('../../lib/complexity.rb', __FILE__)

RSpec.configure do |c|
  c.include Helpers
  c.include Complexity
end