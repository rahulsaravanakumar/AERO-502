require "rails_helper"

# KAN-24: estimated hours and members' logged hours are tracked together.
RSpec.describe "Planned vs. actual effort", type: :request do
     it "accepts a zero estimate and rejects a negative one (reconciled with KAN-8 and KAN-10)" do
          sign_in(users(:officer))

          patch task_path(tasks(:wing_test)), params: { task: { estimated_hours: "0" } }
          expect(tasks(:wing_test).reload.estimated_hours).to eq(0)

          patch task_path(tasks(:wing_test)), params: { task: { estimated_hours: "-1" } }
          expect(response.body).to include("Estimated hours must be greater than or equal to 0")
          expect(tasks(:wing_test).reload.estimated_hours).to eq(0)
     end

     it "states on the task how far actual hours are from the estimate" do
          sign_in(users(:member))
          get task_path(tasks(:wing_test))

          effort = response.parsed_body.at_css(".effort-numbers")
          expect(effort.css("strong").map(&:text)).to eq([ "10h", "2.5h", "-7.5h" ])
          expect(response.parsed_body.at_css("[data-variance]").text).to eq("7.5 hours under estimate")
     end

     it "shows each member's estimated hours, actual hours and difference in the leader summary" do
          TimeEntry.create!(task: tasks(:wing_test), user: users(:member), hours: 9, worked_on: Date.new(2026, 9, 28))
          sign_in(users(:chief))
          get dashboard_path

          rows = response.parsed_body.css("[data-member-hours] tbody tr").to_h do |row|
               cells = row.css("th, td").map { |cell| cell.text.squish }
               [ cells.first, cells.drop(1) ]
          end
          expect(response.parsed_body.css("[data-member-hours] thead th").map(&:text)).to include("Difference")
          expect(rows["Morgan Member"]).to eq([ "10 hours", "11.5 hours", "1.5 hours over estimate" ])
          expect(rows["Bailey Member"]).to eq([ "4 hours", "1.5 hours", "2.5 hours under estimate" ])
          expect(rows["Project total"]).to eq([ "14 hours", "13 hours", "1 hour under estimate" ])
     end
end
