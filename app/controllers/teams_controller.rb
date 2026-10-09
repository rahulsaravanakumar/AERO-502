class TeamsController < OrganizationRecordsController
     private

     def model_class
          Team
     end

     def parent_field
          nil
     end

     # Only the Chief Engineer creates, renames or archives teams.
     def officer_managed?
          false
     end
end
