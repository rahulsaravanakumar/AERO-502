require "rails_helper"

# KAN-15 / scope S13 / UAT D4: the administration guide covers what the
# Chief Engineer needs without developer help.
RSpec.describe "Administration guide" do
     let(:guide) { Rails.root.join("docs/ADMIN_GUIDE.md").read }

     def section(title)
          guide[/^## #{Regexp.escape(title)}\n(.*?)(?=^## |\z)/m, 1].to_s
     end

     it "D4.7: explains approving a person, changing their role and removing access on the People screen" do
          steps = section("People and access")

          expect(steps).to include("Add person", "Change role", "Remove access", "Restore access")
          expect(steps).to match(/^1\. /)
     end

     it "D4.8: separates first-time seed setup from the Teams management screen" do
          expect(section("First-time organization setup")).to include("db:seed")
          expect(section("Managing teams, subteams and projects")).to include("Add subteam", "Add project", "Archive")
     end

     it "D4.6: lists ownership, cost, support, backup location and configuration names without secret values" do
          support = section("Ownership and support")
          expect(support).to include("Application owner", "Hosting plan and cost", "Support contact", "Backup location")

          config = section("Configuration")
          %w[DATABASE_URL RAILS_MASTER_KEY GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET PASSWORD_SIGN_IN DEMO_PASSWORD].each do |name|
               expect(config).to include(name)
          end
          expect(guide).not_to match(/AeroSprint1!|GOCSPX-|[0-9a-f]{32}/)
     end

     it "D4.4/D4.5: gives update, rollback, backup and restore as numbered steps and says what a restore loses" do
          %w[Update\ procedure Simulated\ failed\ update\ and\ rollback Database\ backup\ and\ restore].each do |title|
               expect(section(title)).to match(/^1\. /), "#{title} should use numbered steps"
          end
          expect(section("Database backup and restore")).to include("changes made after the backup are lost")
     end
end
