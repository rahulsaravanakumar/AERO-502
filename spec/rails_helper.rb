ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require_relative "../config/environment"
abort("RSpec must run in the test environment") unless Rails.env.test?
require "rspec/rails"
Rails.application.eager_load!

Rails.root.glob("spec/support/**/*.rb").each { |file| require file }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
     config.fixture_paths = [ Rails.root.join("spec/fixtures") ]
     config.global_fixtures = :all
     config.use_transactional_fixtures = true
     config.infer_spec_type_from_file_location!
     config.filter_rails_from_backtrace!
end
