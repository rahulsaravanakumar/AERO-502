require "rails_helper"

RSpec.describe "Organization membership integrity" do
     it "requires roster membership to belong to its class and validates missing parents" do
          membership = SubteamMembership.new(team_membership: team_memberships(:member), subteam: subteams(:airframe), joined_at: Time.current)
          expect(membership).not_to be_valid
          expect(membership.errors[:subteam]).to include("must belong to the member's class")
          expect(SubteamMembership.new.valid?).to be_falsey
          expect(SubteamMembership.new(subteam: subteams(:wing)).valid?).to be_falsey
          expect(SubteamMembership.new(team_membership: team_memberships(:member)).valid?).to be_falsey
     end

     it "ends old class and subteam memberships together while retaining their history" do
          person = users(:member)
          person.update!(subteam: subteams(:wing))
          old_class = person.team_memberships.first
          person.update!(team: teams(:structures), subteam: subteams(:airframe))
          expect(old_class.reload.ended_at).to be_present
          expect(old_class.subteam_memberships.first.ended_at).to be_present
          expect(person.reload.team).to eq(teams(:structures))
          expect(person.subteam).to eq(subteams(:airframe))
          expect(User.column_names).not_to include("team_id", "subteam_id", "role")
          expect(User.officer).to include(users(:officer))
     end

     it "ends subteam membership atomically with its class and permits rejoining" do
          person = users(:member)
          person.update!(subteam: subteams(:wing))
          membership = person.team_memberships.first
          membership.update!(ended_at: Time.current)
          expect(membership.subteam_memberships.active).to be_empty
          expect(person.reload.team).to be_nil
          expect(person.role).to eq("member")
          membership.update!(ended_at: nil)
          expect(person.reload.team).to eq(teams(:aerodynamics))
     end

     it "rejects invalid primary roles and supports a chief initialized through the global role" do
          person = users(:member)
          person.role = "unknown"
          expect(person).not_to be_valid
          expect(person.errors[:role]).to be_present
          expect(User.new(global_role: :chief_engineer).role).to eq("chief_engineer")
     end
end
