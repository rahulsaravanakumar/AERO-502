require "test_helper"

class SprintOneWorkflowTest < ActionDispatch::IntegrationTest
     test "protected pages request sign in" do
          get tasks_path

          assert_redirected_to login_path
     end

     test "valid credentials open the role-aware dashboard" do
          sign_in(users(:member))

          assert_redirected_to root_path
          follow_redirect!
          assert_response :success
          assert_includes response.body, "Wing load test"
          assert_not_includes response.body, "Verify spar dimensions"
     end

     test "incorrect password is refused with a clear message" do
          post login_path, params: { email: users(:member).email, password: "wrong" }

          assert_response :unprocessable_entity
          assert_includes response.body, "Email or password is incorrect"
     end

     test "member cannot retrieve another team's task directly" do
          sign_in(users(:member))

          get task_path(tasks(:spar_check))

          assert_redirected_to root_path
     end

     test "assigned member updates status and records hours" do
          sign_in(users(:member))

          patch task_path(tasks(:wing_test)), params: { task: { status: "in_progress" } }
          assert_redirected_to task_path(tasks(:wing_test))
          assert tasks(:wing_test).reload.in_progress?

          assert_difference("TimeEntry.count", 1) do
               post task_time_entries_path(tasks(:wing_test)), params: {
                    time_entry: { hours: 1.5, worked_on: Date.current, note: "Test run" }
               }
          end
     end

     test "negative hours are rejected and previous total remains" do
          sign_in(users(:member))
          previous_total = tasks(:wing_test).total_actual_hours

          assert_no_difference("TimeEntry.count") do
               post task_time_entries_path(tasks(:wing_test)), params: {
                    time_entry: { hours: -1, worked_on: Date.current }
               }
          end
          assert_equal previous_total, tasks(:wing_test).reload.total_actual_hours
     end

     test "team officer creates and assigns a complete task card" do
          sign_in(users(:officer))

          assert_difference([ "Task.count", "TaskAssignment.count" ], 1) do
               post tasks_path, params: {
                    task: {
                         title: "Control surface check",
                         description: "Deliver a checked control-surface worksheet.",
                         instructions: "Use drawing revision B.",
                         link_url: "https://example.com/control",
                         due_date: 1.week.from_now.to_date,
                         estimated_hours: 3.5,
                         status: "backlog",
                         project_id: projects(:aero).id,
                         team_id: teams(:structures).id,
                         assignee_ids: [ users(:member).id ]
                    }
               }
          end

          task = Task.order(:created_at).last
          assert_redirected_to task_path(task)
          assert_equal teams(:aerodynamics), task.team
          assert_equal [ users(:member) ], task.assignees
     end

     test "officer cannot edit another team's task" do
          sign_in(users(:officer))

          get edit_task_path(tasks(:spar_check))

          assert_redirected_to root_path
     end

     private

     def sign_in(user)
          post login_path, params: { email: user.email, password: "password" }
     end
end
