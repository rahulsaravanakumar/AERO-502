require "rails_helper"

RSpec.describe "Sprint 1 workflow", type: :request do
     it "protected pages request sign in" do
          get tasks_path

          expect(response).to redirect_to(login_path)
     end

     it "valid credentials open the role-aware dashboard" do
          sign_in(users(:member))

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response).to have_http_status(:success)
          expect(response.body).to include("Wing load test")
          expect(response.body).not_to include("Verify spar dimensions")
     end

     it "incorrect password is refused with a clear message" do
          post login_path, params: { email: users(:member).email, password: "wrong" }

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Email or password is incorrect")
     end

     it "member cannot retrieve another team's task directly" do
          sign_in(users(:member))

          get task_path(tasks(:spar_check))

          expect(response).to redirect_to(root_path)
     end

     it "assigned member updates status and records hours" do
          sign_in(users(:member))

          patch task_path(tasks(:wing_test)), params: { task: { status: "in_progress" } }
          expect(response).to redirect_to(task_path(tasks(:wing_test)))
          expect(tasks(:wing_test).reload.in_progress?).to be_truthy

          expect do
               post task_time_entries_path(tasks(:wing_test)), params: {
                    time_entry: { hours: 1.5, worked_on: Date.current, note: "Test run" }
               }
          end.to change(TimeEntry, :count).by(1)
     end

     it "negative hours are rejected and previous total remains" do
          sign_in(users(:member))
          previous_total = tasks(:wing_test).total_actual_hours

          expect do
               post task_time_entries_path(tasks(:wing_test)), params: {
                    time_entry: { hours: -1, worked_on: Date.current }
               }
          end.not_to change(TimeEntry, :count)
          expect(tasks(:wing_test).reload.total_actual_hours).to eq(previous_total)
     end

     it "team officer creates and assigns a complete task card" do
          sign_in(users(:officer))

          expect do
               post tasks_path, params: {
                    task: {
                         title: "Control surface check",
                         description: "Deliver a checked control-surface worksheet.",
                         instructions: "Use drawing revision B.",
                         reference_links_text: "https://example.com/control",
                         due_date: 1.week.from_now.to_date,
                         estimated_hours: 3.5,
                         status: "backlog",
                         project_id: projects(:aero).id,
                         team_id: teams(:structures).id,
                         assignee_ids: [ users(:member).id ]
                    }
               }
          end.to change(Task, :count).by(1).and change(TaskAssignment, :count).by(1)

          task = Task.order(:created_at).last
          expect(response).to redirect_to(task_path(task))
          expect(task.team).to eq(teams(:aerodynamics))
          expect(task.assignees).to eq([ users(:member) ])
     end

     it "officer cannot edit another team's task" do
          sign_in(users(:officer))

          get edit_task_path(tasks(:spar_check))

          expect(response).to redirect_to(root_path)
     end

     private

     def sign_in(user)
          post login_path, params: { email: user.email, password: "password" }
     end
end
