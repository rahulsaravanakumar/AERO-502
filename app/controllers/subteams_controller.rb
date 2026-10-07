class SubteamsController < OrganizationRecordsController
     private

     def model_class
          Subteam
     end

     def parent_field
          :team_id
     end

     def parent_options
          Team.where(id: team_ids_for_choices).order(:name)
     end

     def team_id_for(subteam)
          subteam.team_id
     end
end
