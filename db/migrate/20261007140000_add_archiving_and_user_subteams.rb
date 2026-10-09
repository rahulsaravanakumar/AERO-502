class AddArchivingAndUserSubteams < ActiveRecord::Migration[8.1]
     def change
          add_column :projects, :archived_at, :datetime
          add_column :teams, :archived_at, :datetime
          add_column :subteams, :archived_at, :datetime
          add_reference :users, :subteam, foreign_key: true
     end
end
