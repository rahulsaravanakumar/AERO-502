require "rails_helper"

# KAN-25: sign in with a Google (TAMU) account on the allowed-users list.
RSpec.describe "Google sign-in", type: :request do
     before { OmniAuth.config.test_mode = true }
     after { OmniAuth.config.mock_auth[:google_oauth2] = nil }

     def google_sign_in(email, verified: true)
          OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
               provider: "google_oauth2", uid: "google-#{email}",
               info: { email: email, name: "Google Name" },
               extra: { raw_info: { email_verified: verified } }
          )
          post "/auth/google_oauth2"
          follow_redirect!
     end

     it "offers Sign in with Google on the sign-in page" do
          get login_path

          expect(response.parsed_body.at_css("form[action='/auth/google_oauth2'] button").text).to include("Sign in with Google")
     end

     it "signs in an allowed email with the role and team assigned to it, ignoring letter case" do
          google_sign_in("Officer@Example.TEST")

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include("Olivia Officer · Officer", "Wing load test")
     end

     it "refuses accounts that are not on the list or whose email Google has not verified" do
          [ [ "stranger@tamu.edu", true ], [ users(:member).email, false ] ].each do |email, verified|
               google_sign_in(email, verified: verified)

               expect(response).to redirect_to(login_path)
               follow_redirect!
               expect(response.body).to include("Access not authorized")
               get tasks_path
               expect(response).to redirect_to(login_path)
          end
     end

     it "explains a cancelled or failed Google sign-in" do
          get "/auth/failure", params: { message: "access_denied" }

          expect(response).to redirect_to(login_path)
          expect(flash[:alert]).to eq("Google sign-in was cancelled or failed. Please try again.")
     end

     it "lets the Chief Engineer add an allowed person who can then sign in on the first try" do
          sign_in(users(:chief))
          get new_user_path
          expect(response).to have_http_status(:ok)

          expect do
               post users_path, params: { user: {
                    name: "Riley Recruit", email: "Riley@TAMU.edu", role: "member",
                    team_id: teams(:aerodynamics).id, subteam_id: subteams(:wing).id
               } }
          end.to change(User, :count).by(1)
          expect(response).to redirect_to(users_path)
          expect(User.find_by(email: "riley@tamu.edu")).to have_attributes(password_digest: nil, subteam: subteams(:wing))

          delete logout_path
          google_sign_in("riley@tamu.edu")
          follow_redirect!
          expect(response.body).to include("Riley Recruit · Member")
     end

     it "shows errors when an added person is incomplete" do
          sign_in(users(:chief))

          expect { post users_path, params: { user: { name: "", email: "bad", role: "member" } } }
               .not_to change(User, :count)
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body.at_css("#user_email_error").text).to include("Email is invalid")
     end

     it "signs a removed person out at their next page load but keeps their tasks and hours" do
          member = users(:member)
          google_sign_in(member.email)

          member.update!(access_revoked_at: Time.current)

          get tasks_path
          expect(response).to redirect_to(login_path)
          expect(flash[:alert]).to include("Access not authorized")
          expect(member.time_entries.count).to eq(1)
          expect(tasks(:wing_test).assignees).to include(member)

          google_sign_in(member.email)
          expect(response).to redirect_to(login_path)
          post login_path, params: { email: member.email, password: "password" }
          expect(response.body).to include("Access not authorized")
     end

     it "lets the Chief Engineer remove and restore a person's access from the People screen" do
          sign_in(users(:chief))

          patch revoke_user_path(users(:member))
          expect(response).to redirect_to(users_path)
          expect(users(:member).reload.access_revoked_at).to be_present
          get users_path
          expect(response.body).to include("Access removed")

          patch restore_user_path(users(:member))
          expect(users(:member).reload.access_revoked_at).to be_nil
     end

     it "gives officers and members no option to add or remove allowed people" do
          [ users(:officer), users(:member) ].each do |user|
               sign_in(user)
               get new_user_path
               expect(response).to redirect_to(root_path)
               expect { post users_path, params: { user: { name: "X", email: "x@tamu.edu", role: "member" } } }
                    .not_to change(User, :count)
               patch revoke_user_path(users(:other_member))
               expect(users(:other_member).reload.access_revoked_at).to be_nil
          end
     end

     it "refuses password sign-in when it has been turned off" do
          allow(Rails.configuration.x).to receive(:password_sign_in).and_return(false)
          post login_path, params: { email: users(:member).email, password: "password" }

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Password sign-in is turned off. Use Sign in with Google.")
     end

     it "refuses password sign-in for a person who has no password" do
          person = User.create!(name: "Google Only", email: "google.only@tamu.edu", role: :member, team: teams(:aerodynamics))
          post login_path, params: { email: person.email, password: "" }

          expect(response.body).to include("Access not authorized")
     end
end
