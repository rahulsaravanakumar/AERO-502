require "rails_helper"

# KAN-17 / scope S15 / UAT D2: a user guide members can open from the website.
RSpec.describe "User guide", type: :request do
     it "D2.7: is linked from the header and from the sign-in page" do
          get login_path
          expect(response.parsed_body.at_css("a[href='#{help_path}']")).to be_present

          sign_in(users(:member))
          get tasks_path
          expect(response.parsed_body.at_css("header a[href='#{help_path}']").text).to eq("Help")
     end

     it "opens without signing in so people who cannot sign in can read what to do" do
          get help_path

          expect(response).to have_http_status(:ok)
          headings = response.parsed_body.css("main h2").map(&:text)
          expect(headings).to include("Sign in", "Record actual hours", "Messages and what to do")
     end

     it "D2.6: explains every message the website shows, with a next step" do
          get help_path
          guide = response.parsed_body.at_css("main").text.squish

          [
               "Access not authorized", "Your access has been removed", "Please sign in to view that page",
               "can't be blank", "Hours is not a number", "Hours must be greater than 0",
               "a member can record at most 24 hours per day", "Due date must be on or after the start date",
               "End date must be on or after the start date", "is not a valid date",
               "must each be a full web address starting with http:// or https://",
               TasksController::OWN_TEAM_ONLY, "You can update only tasks assigned to you.",
               "You cannot view that task.", "You can change only your own hours.",
               "The timeline is available to team officers and the Chief Engineer.",
               "Only the Chief Engineer can manage people and roles.",
               "You can manage only your own team's subteams and projects.",
               "Google sign-in was cancelled or failed"
          ].each do |message|
               expect(guide).to include(message)
          end
     end

     it "D2.3: contains no passwords and renders as safe HTML" do
          get help_path

          expect(response.body).not_to include(ENV.fetch("DEMO_PASSWORD", "AeroSprint1!"))
          expect(response.parsed_body.css("main script")).to be_empty
          expect(response.parsed_body.css("main table")).to be_present
     end
end
