require "rails_helper"

# KAN-8: members see the estimated hours for each assigned task.
RSpec.describe "Estimated hours display", type: :request do
     it "shows the saved estimate with an Estimated hours label to the assigned member" do
          sign_in(users(:member))
          get task_path(tasks(:wing_test))

          estimate = response.parsed_body.at_css("[data-estimate]")
          expect(estimate.text).to include("Estimated hours")
          expect(estimate.text).to include("10 hours")
     end

     it "shows a saved zero estimate as 0 hours" do
          tasks(:wing_test).update!(estimated_hours: 0)
          sign_in(users(:member))
          get task_path(tasks(:wing_test))

          expect(response.parsed_body.at_css("[data-estimate]").text).to include("0 hours")
     end

     it "persists a decimal estimate entered by the team officer after reopening the task" do
          sign_in(users(:officer))
          patch task_path(tasks(:wing_test)), params: { task: { estimated_hours: "7.5" } }
          get task_path(tasks(:wing_test))

          expect(response.parsed_body.at_css("[data-estimate]").text).to include("7.5 hours")
     end

     it "rejects nonnumeric and negative estimates and keeps the last valid value" do
          sign_in(users(:officer))

          [ "abc", "-2" ].each do |value|
               patch task_path(tasks(:wing_test)), params: { task: { estimated_hours: value } }

               expect(response).to have_http_status(:unprocessable_content)
               expect(response.body).to include("Estimated hours")
               expect(tasks(:wing_test).reload.estimated_hours).to eq(10)
          end
     end

     it "does not let the assigned member change the estimate" do
          sign_in(users(:member))
          patch task_path(tasks(:wing_test)), params: { task: { status: "in_progress", estimated_hours: "1" } }

          expect(tasks(:wing_test).reload.estimated_hours).to eq(10)
     end

     it "does not let an officer change another team's estimate" do
          sign_in(users(:officer))
          patch task_path(tasks(:spar_check)), params: { task: { estimated_hours: "1" } }

          expect(response).to redirect_to(root_path)
          expect(tasks(:spar_check).reload.estimated_hours).to eq(4)
     end
end
