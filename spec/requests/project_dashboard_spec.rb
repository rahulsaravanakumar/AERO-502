require "rails_helper"

# KAN-11: leaders review progress and member workload on a project dashboard.
RSpec.describe "Project dashboard", type: :request do
     around { |example| travel_to(Date.new(2026, 10, 3)) { example.run } }

     before do
          TimeEntry.create!(task: tasks(:wing_test), user: users(:member), hours: 1, worked_on: Date.new(2026, 9, 30))
     end

     def summary_rows
          response.parsed_body.css("[data-member-hours] tbody tr").to_h do |row|
               cells = row.css("th, td").map { |cell| cell.text.squish }
               [ cells.first, cells.drop(1) ]
          end
     end

     it "shows status counts, each member's assigned tasks and only unfinished overdue tasks" do
          sign_in(users(:chief))
          get dashboard_path(project_id: projects(:aero).id)

          page = response.parsed_body
          counts = page.css(".metrics [data-status]").to_h { |metric| [ metric["data-status"], metric.at_css("strong").text ] }
          expect(counts).to eq("backlog" => "1", "in_progress" => "1", "completed" => "0")
          assignments = page.at_css("[data-assignments]").text.squish
          expect(assignments).to include("Morgan Member Wing load test", "Bailey Member Verify spar dimensions")
          overdue = page.css("[data-overdue] li").map { |item| item.text.squish }
          expect(overdue).to eq([ "Verify spar dimensions Structures · due October 01, 2026 · In progress" ])
     end

     it "never lists completed tasks as overdue" do
          tasks(:spar_check).update!(status: :completed)
          sign_in(users(:chief))
          get dashboard_path

          expect(response.body).to include("No overdue tasks")
     end

     it "summarizes each member's estimated and actual hours for a date range as a table and a chart" do
          sign_in(users(:chief))
          get dashboard_path(from: "2026-09-28", to: "2026-09-30")

          expect(summary_rows).to include(
               "Morgan Member" => [ "10 hours", "1 hour" ],
               "Bailey Member" => [ "4 hours", "0 hours" ],
               "Project total" => [ "14 hours", "1 hour" ]
          )
          chart = response.parsed_body.css("[data-member-chart] [data-member]").to_h do |bar|
               [ bar["data-member"], bar["data-actual"] ]
          end
          expect(chart).to eq("Bailey Member" => "0.0", "Morgan Member" => "1.0")
     end

     it "includes both endpoint dates and labels shared estimates without double counting them" do
          tasks(:wing_test).assignees << User.create!(name: "Sam Second", email: "sam@example.test",
                                                      password: "password", role: :member, team: teams(:aerodynamics))
          sign_in(users(:chief))
          get dashboard_path(from: "2026-09-27", to: "2026-09-30")

          expect(response.body).to include("Assigned-task estimate (shared)")
          expect(summary_rows).to include(
               "Morgan Member" => [ "10 hours", "3.5 hours" ],
               "Sam Second" => [ "10 hours", "0 hours" ],
               "Project total" => [ "14 hours", "5 hours" ]
          )
     end

     it "rejects an end date earlier than the start date and keeps showing all hours" do
          sign_in(users(:chief))
          get dashboard_path(from: "2026-09-30", to: "2026-09-01")

          expect(response.body).to include("End date must be on or after the start date")
          expect(summary_rows["Project total"]).to eq([ "14 hours", "5 hours" ])
     end

     it "ignores dates that cannot be read" do
          sign_in(users(:chief))
          get dashboard_path(from: "not-a-date")

          expect(response.body).to include("Start date is not a valid date")
          expect(summary_rows["Project total"]).to eq([ "14 hours", "5 hours" ])
     end

     it "shows a team officer only their own team" do
          sign_in(users(:officer))
          get dashboard_path

          expect(response.body).to include("Wing load test")
          expect(response.body).not_to include("Verify spar dimensions", "Bailey Member")
     end

     it "denies members with a clear message" do
          sign_in(users(:member))
          get dashboard_path

          expect(response).to redirect_to(tasks_path)
          expect(flash[:alert]).to eq("The project dashboard is available to team officers and the Chief Engineer.")
     end

     it "shows new values after a status or hours change when the leader refreshes" do
          sign_in(users(:chief))
          get dashboard_path
          tasks(:wing_test).update!(status: :completed)
          TimeEntry.create!(task: tasks(:wing_test), user: users(:member), hours: 2, worked_on: Date.new(2026, 10, 1))

          get dashboard_path
          completed = response.parsed_body.at_css(".metrics [data-status='completed'] strong").text
          expect(completed).to eq("1")
          expect(summary_rows["Morgan Member"]).to eq([ "10 hours", "5.5 hours" ])
     end
end
