require "rails_helper"

RSpec.describe Task, type: :model do
     it "rejects subteams from another team" do
          task = tasks(:wing_test)
          task.subteam = subteams(:airframe)
          expect(task).not_to be_valid
          expect(task.errors[:subteam]).to include("must belong to the selected team")
     end

     it "calculates member hours consistently with preloaded entries" do
          task = tasks(:wing_test)
          task.time_entries.load
          expect(task.actual_hours_for(users(:member))).to eq(2.5)
          expect(task.actual_hours_for(users(:other_member))).to eq(0)
     end
     it "rejects a negative estimate without changing the saved value" do
          task = tasks(:wing_test)
          task.estimated_hours = -1

          expect(task.save).to be_falsey
          expect(task.errors[:estimated_hours]).to include("must be greater than or equal to 0")
          expect(task.reload.estimated_hours).to eq(10)
     end

     it "accessible scope follows role and assignment" do
          expect(Task.accessible_to(users(:chief)).count).to eq(2)
          expect(Task.accessible_to(users(:officer)).to_a).to eq([ tasks(:wing_test) ])
          expect(Task.accessible_to(users(:member)).to_a).to eq([ tasks(:wing_test) ])
          expect(Task.accessible_to(users(:member)).where(id: tasks(:spar_check))).to be_empty
     end

     it "reports actual totals and variance" do
          task = tasks(:wing_test)

          expect(task.total_actual_hours).to eq(2.5)
          expect(task.actual_hours_for(users(:member))).to eq(2.5)
          expect(task.variance_hours).to eq(-7.5)
     end

     it "requires a valid supporting link when present" do
          task = tasks(:wing_test)
          task.link_url = "not a link"

          expect(task.valid?).to be_falsey
          expect(task.errors[:link_url]).to include("must start with http:// or https://")
     end
end
