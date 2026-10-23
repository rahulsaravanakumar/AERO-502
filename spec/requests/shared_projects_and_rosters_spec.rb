require "rails_helper"

RSpec.describe "Shared projects and subteam rosters", type: :request do
     let(:team) { teams(:aerodynamics) }
     let(:wing) { subteams(:wing) }
     let(:project) { projects(:aero) }
     let(:member) { users(:member) }
     let(:second) { Subteam.create!(team: team, name: "Propulsion") }

     def add_project(subteams, parent: team, name: "Shared aircraft")
          post projects_path, params: { project: { name: name, team_id: parent.id, subteam_ids: subteams.map(&:id) } }
     end

     it "creates a team-owned project shared by subteams and keeps each task's responsible subteam" do
          sign_in(users(:officer))
          add_project([ wing, second ])
          expect(response).to redirect_to(organization_path)
          shared = Project.find_by!(name: "Shared aircraft")
          expect(shared.subteams).to contain_exactly(wing, second)
          [ wing, second ].each do |subteam|
               post tasks_path, params: { task: { title: "Build #{subteam.name}", project_id: shared.id,
                    subteam_id: subteam.id, estimated_hours: 2, start_date: Date.current, due_date: Date.current + 7,
                    assignee_ids: [ member.id ] } }
               expect(response).to redirect_to(task_path(Task.order(:id).last))
          end
          get tasks_path(filter: { project_id: shared.id })
          expect(response.body).to include("Build Wing Analysis", "Build Propulsion")
          get tasks_path(filter: { project_id: shared.id, subteam_id: second.id })
          expect(response.body).to include("Build Propulsion")
          expect(response.body).not_to include("Build Wing Analysis")
          get timeline_path(filter: { project_id: shared.id })
          expect(response.body).to include("Build Wing Analysis", "Build Propulsion")
     end

     it "rejects a foreign parent, foreign participating subteam, missing subteams and duplicate project name" do
          sign_in(users(:officer))
          expect { add_project([ subteams(:airframe) ], parent: teams(:structures)) }.not_to change(Project, :count)
          expect(response).to redirect_to(organization_path)
          get new_project_path(team_id: teams(:structures).id)
          expect(response).to redirect_to(organization_path)
          [ [ wing, subteams(:airframe) ], [] ].each do |subteams|
               expect { add_project(subteams) }.not_to change(Project, :count)
               expect(response).to have_http_status(:unprocessable_content)
          end
          expect { add_project([ wing ], name: project.name.upcase) }.not_to change(Project, :count)
          expect(response).to have_http_status(:unprocessable_content)
     end

     it "changes project participation without deleting existing tasks or reparenting the project" do
          sign_in(users(:chief))
          patch project_path(project), params: { project: { subteam_ids: [ wing.id, second.id ] } }
          expect(project.reload.subteams).to contain_exactly(wing, second)
          patch project_path(project), params: { project: { subteam_ids: [ second.id ] } }
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("cannot remove a subteam with recorded tasks")
          expect(tasks(:wing_test).reload.project).to eq(project)
          patch project_path(project), params: { project: { team_id: teams(:structures).id, subteam_ids: [ wing.id ] } }
          expect(project.reload.team).to eq(team)
          expect(project.subteams).to contain_exactly(wing)
     end

     it "requires a valid responsible subteam for shared projects and rejects cross-team task ownership" do
          project.project_subteams.create!(subteam: second)
          sign_in(users(:officer))
          base = { title: "Choose responsibility", project_id: project.id, estimated_hours: 1, due_date: Date.current + 1 }
          [ {}, { subteam_id: subteams(:airframe).id }, { project_id: projects(:airframe_build).id } ].each do |change|
               expect { post tasks_path, params: { task: base.merge(change) } }.not_to change(Task, :count)
               expect(response).to have_http_status(:unprocessable_content)
               expect(response.body).not_to include("Airframe build")
          end
          sign_in(member)
          expect { post projects_path, params: { project: { name: "No", team_id: team.id } } }.not_to change(Project, :count)
          expect(response).to redirect_to(root_path)
     end

     it "keeps saved task fields, assignees, dates and hours when viewing a shared project" do
          project.project_subteams.create!(subteam: second)
          original = tasks(:wing_test).attributes
          sign_in(users(:chief))
          get project_path(project)
          expect(response.body).to include("Wing load test", "2.5 hours")
          expect(tasks(:wing_test).reload.attributes).to eq(original)
     end

     it "shows roster members with no tasks or hours and adds an approved member independently of assignments" do
          sign_in(users(:officer))
          get subteam_path(wing)
          expect(response.body).to include("No members belong to this subteam yet")
          expect { patch subteam_roster_path(wing), params: { user_id: member.id } }.not_to change(TaskAssignment, :count)
          expect(member.reload.subteam).to eq(wing)
          zero = User.create!(name: "Zero Work", email: "zero@tamu.edu", role: :member, team: team, subteam: wing)
          get subteam_path(wing)
          row = response.parsed_body.at_css("[data-roster-member='#{zero.id}']")
          expect(row.text).to include("No assigned work", "0 hours")
          expect(member.subteam_memberships.active.first.subteam).to eq(wing)
     end

     it "shows a roster member's assignments in another subteam of the same class" do
          member.update!(subteam: second)
          sign_in(users(:officer))
          get subteam_path(second)
          row = response.parsed_body.at_css("[data-roster-member='#{member.id}']")
          expect(row.text).to include("Wing load test", "SAE AERO Design", "Wing Analysis", "2.5 hours")
          expect(row.text).not_to include("No assigned work")
     end

     it "removes only membership, preserves historical work, and can restore the same membership" do
          member.update!(subteam: wing)
          sign_in(users(:officer))
          hours = member.time_entries.sum(:hours)
          assignments = member.assigned_task_ids
          delete subteam_roster_path(wing), params: { user_id: member.id }
          expect(member.reload.subteam).to be_nil
          expect(member.time_entries.sum(:hours)).to eq(hours)
          expect(member.assigned_task_ids).to match_array(assignments)
          expect(member.subteam_memberships.first.ended_at).to be_present
          patch subteam_roster_path(wing), params: { user_id: member.id }
          expect(member.subteam_memberships.count).to eq(1)
          expect(member.subteam_memberships.active.count).to eq(1)
     end

     it "requires removal before adding a second subteam and refuses unknown, revoked or foreign members" do
          member.update!(subteam: wing)
          sign_in(users(:chief))
          patch subteam_roster_path(second), params: { user_id: member.id }
          expect(flash[:alert]).to include("Remove the member's current subteam")
          [ users(:other_member).id, 0 ].each do |id|
               patch subteam_roster_path(wing), params: { user_id: id }
               expect(flash[:alert]).to include("Choose an approved member")
          end
          member.update!(access_revoked_at: Time.current)
          patch subteam_roster_path(wing), params: { user_id: member.id }
          expect(flash[:alert]).to include("Choose an approved member")
          delete subteam_roster_path(second), params: { user_id: 0 }
          expect(flash[:alert]).to include("does not belong")
          delete subteam_roster_path(second), params: { user_id: member.id }
          expect(flash[:alert]).to include("does not belong")
     end

     it "denies direct roster changes and reads to members and officers of another class" do
          [ users(:member), users(:other_officer) ].each do |person|
               sign_in(person)
               get subteam_path(wing)
               expect(response).to redirect_to(person.member? ? root_path : organization_path)
               expect { patch subteam_roster_path(wing), params: { user_id: member.id } }.not_to change(SubteamMembership, :count)
               expect(flash[:alert]).to include("Access denied")
               delete subteam_roster_path(wing), params: { user_id: member.id }
               expect(response).to redirect_to(root_path)
          end
     end

     it "scopes roster work and hours to a project and dates without hiding zero-work members" do
          member.update!(subteam: wing)
          sign_in(users(:chief))
          get subteam_path(wing, filter: { project_id: projects(:archive).id }, from: "2026-10-01", to: "2026-10-02")
          row = response.parsed_body.at_css("[data-roster-member='#{member.id}']")
          expect(row.text).to include("No assigned work", "0 hours")
          get subteam_path(wing, from: "bad-date")
          expect(response.body).to include("Showing hours for all dates")
     end
end
