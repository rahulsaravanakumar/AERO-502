require "test_helper"

class TaskTest < ActiveSupport::TestCase
     test "rejects a negative estimate without changing the saved value" do
          task = tasks(:wing_test)
          task.estimated_hours = -1

          assert_not task.save
          assert_includes task.errors[:estimated_hours], "must be greater than or equal to 0"
          assert_equal 10, task.reload.estimated_hours
     end

     test "accessible scope follows role and assignment" do
          assert_equal 2, Task.accessible_to(users(:chief)).count
          assert_equal [ tasks(:wing_test) ], Task.accessible_to(users(:officer)).to_a
          assert_equal [ tasks(:wing_test) ], Task.accessible_to(users(:member)).to_a
          assert_empty Task.accessible_to(users(:member)).where(id: tasks(:spar_check))
     end

     test "reports actual totals and variance" do
          task = tasks(:wing_test)

          assert_equal 2.5, task.total_actual_hours
          assert_equal 2.5, task.actual_hours_for(users(:member))
          assert_equal(-7.5, task.variance_hours)
     end

     test "requires a valid supporting link when present" do
          task = tasks(:wing_test)
          task.link_url = "not a link"

          assert_not task.valid?
          assert_includes task.errors[:link_url], "must start with http:// or https://"
     end
end
