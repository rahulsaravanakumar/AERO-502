require "rails_helper"

RSpec.describe TimeEntry, type: :model do
     it "requires positive hours" do
          entry = TimeEntry.new(task: tasks(:wing_test), user: users(:member),
                                hours: -2, worked_on: Date.current)

          expect(entry.valid?).to be_falsey
          expect(entry.errors[:hours]).to include("must be greater than 0")
     end

     it "rejects hours from an unassigned member" do
          entry = TimeEntry.new(task: tasks(:wing_test), user: users(:other_member),
                                hours: 1, worked_on: Date.current)

          expect(entry.valid?).to be_falsey
          expect(entry.errors[:user]).to include("must be assigned to the task")
     end
end
