require "test_helper"

class UserTest < ActiveSupport::TestCase
     test "normalizes email before validation" do
          user = User.new(name: "Test Member", email: "  TEST@EXAMPLE.COM ",
                          password: "password", role: :member, team: teams(:aerodynamics))

          assert user.valid?
          assert_equal "test@example.com", user.email
     end

     test "chief engineer may exist without a team" do
          user = users(:chief)

          assert user.valid?
          assert user.leader?
          assert user.can_manage?(tasks(:spar_check))
     end

     test "officer manages only tasks in their team" do
          officer = users(:officer)

          assert officer.can_manage?(tasks(:wing_test))
          assert_not officer.can_manage?(tasks(:spar_check))
     end
end
