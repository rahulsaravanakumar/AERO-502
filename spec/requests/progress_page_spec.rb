require "rails_helper"

# The leader dashboard (KAN-11) is presented as "Progress"; tasks come first in the menu.
RSpec.describe "Progress page", type: :request do
     around { |example| travel_to(Date.new(2026, 10, 3)) { example.run } }

     def nav_links
          response.parsed_body.css("nav[aria-label='Primary navigation'] a").map { |link| link.text.squish }
     end

     it "lists Tasks first, then Progress and Timeline, with Help last" do
          sign_in(users(:chief))
          get tasks_path
          expect(nav_links).to eq([ "Tasks", "My Tasks", "Progress", "Timeline", "Teams", "People", "Help", "New Task" ])

          sign_in(users(:member))
          get tasks_path
          expect(nav_links).to eq([ "Tasks", "My Tasks", "Help" ])
     end

     it "lives at /progress and keeps /dashboard working" do
          sign_in(users(:officer))
          get "/dashboard"
          expect(response).to redirect_to("/progress")

          get dashboard_path
          expect(dashboard_path).to eq("/progress")
          expect(response.parsed_body.at_css("h1").text).to eq("Team progress")
     end

     it "counts overdue tasks alongside the status counts" do
          sign_in(users(:chief))
          get dashboard_path

          expect(response.parsed_body.at_css(".metrics [data-overdue-count] strong").text).to eq("1")
     end

     it "sets the hours date range in the hours section and keeps it when filters change" do
          sign_in(users(:chief))
          get dashboard_path(project_id: projects(:aero).id, from: "2026-09-28", to: "2026-09-30")

          range_form = response.parsed_body.at_css("[data-member-hours] form[data-hours-range]")
          expect(range_form.css("input[type=date]").map { |field| field["name"] }).to eq(%w[from to])
          expect(range_form.at_css("input[name=project_id]")["value"]).to eq(projects(:aero).id.to_s)

          filter_form = response.parsed_body.at_css("form.filter-bar")
          kept = filter_form.css("input[type=hidden]").to_h { |field| [ field["name"], field["value"] ] }
          expect(kept).to include("from" => "2026-09-28", "to" => "2026-09-30")
     end

     it "explains to members that Progress is for leaders" do
          sign_in(users(:member))
          get dashboard_path

          expect(flash[:alert]).to eq("Team progress is available to team officers and the Chief Engineer.")
     end
end
