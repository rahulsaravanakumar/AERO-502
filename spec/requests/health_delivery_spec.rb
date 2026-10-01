require "rails_helper"

RSpec.describe "KAN-14 deployment health", type: :request do
     it "serves the Rails health endpoint without signing in" do
          get rails_health_check_path

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/html")
          expect(response.body).to include('background-color: green')
     end
end
