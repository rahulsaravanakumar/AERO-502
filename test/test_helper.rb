ENV["RAILS_ENV"] ||= "test"
require "simplecov"

SimpleCov.start "rails" do
     enable_coverage :branch
     minimum_coverage 80
     skip "/test/"
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
     class TestCase
          parallelize(workers: :number_of_processors)

          fixtures :all
     end
end
