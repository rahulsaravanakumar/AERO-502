require "simplecov"

SimpleCov.start "rails" do
     enable_coverage :branch
     minimum_coverage 100
     skip "/spec/"
     merging false
end

RSpec.configure do |config|
     config.order = :random
     Kernel.srand config.seed
end
