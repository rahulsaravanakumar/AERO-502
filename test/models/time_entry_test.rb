require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
     test "requires positive hours" do
          entry = TimeEntry.new(task: tasks(:wing_test), user: users(:member),
                                hours: -2, worked_on: Date.current)

          assert_not entry.valid?
          assert_includes entry.errors[:hours], "must be greater than 0"
     end

     test "rejects hours from an unassigned member" do
          entry = TimeEntry.new(task: tasks(:wing_test), user: users(:other_member),
                                hours: 1, worked_on: Date.current)

          assert_not entry.valid?
          assert_includes entry.errors[:user], "must be assigned to the task"
     end
end
