require "rails_helper"

RSpec.describe TaskEvent, type: :model do
     it "describes removals and changes made without a signed-in user" do
          event = TaskEvent.new(task: tasks(:wing_test), action: "unassigned", subject_user: users(:member))

          expect(event.actor_name).to eq("System")
          expect(event.description).to eq("removed Morgan Member")
     end
end
