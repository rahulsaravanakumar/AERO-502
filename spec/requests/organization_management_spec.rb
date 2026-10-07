require "rails_helper"

# KAN-19: leaders manage projects, teams and subteams.
RSpec.describe "Organization management", type: :request do
     it "lets the Chief Engineer create a project, a team under it and a subteam, kept after reopening" do
          sign_in(users(:chief))

          post projects_path, params: { project: { name: "SAE AERO 2027" } }
          project = Project.find_by!(name: "SAE AERO 2027")
          post teams_path, params: { team: { name: "Regular Class", project_id: project.id } }
          team = Team.find_by!(name: "Regular Class")
          post subteams_path, params: { subteam: { name: "Aerodynamics", team_id: team.id } }
          expect(response).to redirect_to(organization_path)

          get organization_path
          tree = response.parsed_body.at_css("[data-project='#{project.id}']").text.squish
          expect(tree).to include("SAE AERO 2027", "Regular Class", "Aerodynamics")
          expect(team.reload.project).to eq(project)
          expect(team.subteams.map(&:name)).to eq([ "Aerodynamics" ])

          get new_task_path
          options = response.parsed_body.css("#task_team_id option, #task_subteam_id option").map(&:text)
          expect(options).to include("Regular Class", "Aerodynamics")
     end

     it "refuses to save a missing name or parent and identifies the missing field" do
          sign_in(users(:chief))

          expect { post teams_path, params: { team: { name: "", project_id: "" } } }.not_to change(Team, :count)
          expect(response).to have_http_status(:unprocessable_content)
          page = response.parsed_body
          expect(page.at_css("#team_name_error").text).to include("Name can't be blank")
          expect(page.at_css("#team_project_error").text).to include("Project must exist")

          expect { post subteams_path, params: { subteam: { name: "Wings" } } }.not_to change(Subteam, :count)
          expect(response.parsed_body.at_css("#subteam_team_error").text).to include("Team must exist")

          expect { post projects_path, params: { project: { name: "" } } }.not_to change(Project, :count)
          expect(response.parsed_body.at_css("#project_name_error").text).to include("Name can't be blank")
     end

     it "lets the Chief Engineer rename and archive records, which leave everyday lists but keep their tasks" do
          sign_in(users(:chief))

          patch team_path(teams(:structures)), params: { team: { name: "Micro Class" } }
          expect(teams(:structures).reload.name).to eq("Micro Class")
          patch subteam_path(subteams(:airframe)), params: { subteam: { name: "Structures" } }
          patch project_path(projects(:archive)), params: { project: { name: "Old project" } }
          expect(projects(:archive).reload.name).to eq("Old project")

          patch archive_team_path(teams(:structures))
          patch archive_subteam_path(subteams(:wing))
          patch archive_project_path(projects(:archive))
          expect(teams(:structures).reload).to be_archived

          get new_task_path
          options = response.parsed_body.css("select option").map(&:text)
          expect(options).not_to include("Micro Class", "Wing Analysis", "Old project")

          get organization_path
          archived = response.parsed_body.at_css("[data-archived]").text
          expect(archived).to include("Micro Class", "Wing Analysis", "Old project")

          get task_path(tasks(:spar_check))
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Verify spar dimensions", "1.5 hours")

          patch restore_team_path(teams(:structures))
          expect(teams(:structures).reload).not_to be_archived
     end

     it "lets an officer manage only their own team's subteams, including direct requests" do
          sign_in(users(:officer))
          get new_subteam_path
          expect(response.parsed_body.css("#subteam_team_id option").map(&:text)).to eq([ "Select a team", "Aerodynamics" ])
          get new_team_path
          expect(response).to redirect_to(organization_path)

          post subteams_path, params: { subteam: { name: "Wind Tunnel", team_id: teams(:aerodynamics).id } }
          expect(Subteam.find_by(name: "Wind Tunnel").team).to eq(teams(:aerodynamics))
          patch subteam_path(subteams(:wing)), params: { subteam: { name: "Wing Design" } }
          expect(subteams(:wing).reload.name).to eq("Wing Design")
          patch archive_subteam_path(subteams(:wing))
          expect(subteams(:wing).reload).to be_archived

          expect do
               post subteams_path, params: { subteam: { name: "Sneaky", team_id: teams(:structures).id } }
          end.not_to change(Subteam, :count)
          patch subteam_path(subteams(:airframe)), params: { subteam: { name: "Hijacked" } }
          patch subteam_path(subteams(:wing)), params: { subteam: { team_id: teams(:structures).id } }
          patch archive_subteam_path(subteams(:airframe))
          expect(subteams(:airframe).reload).to have_attributes(name: "Airframe", archived_at: nil)
          expect(subteams(:wing).reload.team).to eq(teams(:aerodynamics))

          expect { post teams_path, params: { team: { name: "New", project_id: projects(:aero).id } } }
               .not_to change(Team, :count)
          patch archive_project_path(projects(:aero))
          expect(projects(:aero).reload).not_to be_archived
          expect(response).to redirect_to(organization_path)
     end

     it "shows officers only their own team's structure and members no organization screen" do
          sign_in(users(:officer))
          get organization_path
          expect(response.body).to include("Aerodynamics", "Wing Analysis")
          expect(response.body).not_to include("Airframe")

          sign_in(users(:member))
          get organization_path
          expect(response).to redirect_to(root_path)
          get new_subteam_path
          expect(response).to redirect_to(root_path)
     end

     it "opens the create and rename forms for each kind of record" do
          sign_in(users(:chief))

          [ new_project_path, new_team_path, new_subteam_path(team_id: teams(:aerodynamics).id),
            edit_project_path(projects(:aero)), edit_team_path(teams(:aerodynamics)),
            edit_subteam_path(subteams(:wing)) ].each do |path|
               get path
               expect(response).to have_http_status(:ok)
          end
          patch team_path(teams(:aerodynamics)), params: { team: { name: "" } }
          expect(response).to have_http_status(:unprocessable_content)
     end

     it "lets the Chief Engineer place a person in a subteam of their team" do
          sign_in(users(:chief))

          patch user_path(users(:member)), params: { user: { subteam_id: subteams(:wing).id } }
          expect(users(:member).reload.subteam).to eq(subteams(:wing))

          patch user_path(users(:member)), params: { user: { subteam_id: subteams(:airframe).id } }
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Subteam must belong to the person&#39;s team")
     end

     it "seeds the SAE AERO classes and subteams" do
          expect { load Rails.root.join("db/seeds.rb") }.to output(/Seeded SAE AERO practice data/).to_stdout

          project = Project.find_by!(name: "SAE AERO")
          structure = project.teams.includes(:subteams).to_h { |team| [ team.name, team.subteams.map(&:name).sort ] }
          expect(structure).to eq(
               "Regular Class" => [ "Aerodynamics", "Structures" ],
               "Micro Class" => [ "Aerodynamics", "Structures" ],
               "Advanced Class" => [ "Aerodynamics", "Autonomous Systems", "Structures" ]
          )
     end
end
