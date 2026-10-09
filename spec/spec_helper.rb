require "simplecov"

SimpleCov.start "rails" do
     enable_coverage :branch
     minimum_coverage line: 100, branch: 100
     skip "/spec/"
     merging false
end

RSpec.configure do |config|
     config.order = :random
     Kernel.srand config.seed
end
