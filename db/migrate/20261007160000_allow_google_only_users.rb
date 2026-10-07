class AllowGoogleOnlyUsers < ActiveRecord::Migration[8.1]
     def change
          # People added to the allowed list sign in with Google and may have no password.
          change_column_null :users, :password_digest, true
          add_column :users, :access_revoked_at, :datetime
     end
end
