class SubteamsController < OrganizationRecordsController
     private

     def model_class
          Subteam
     end

     def parent_field
          :team_id
     end

     def parent_options
          teams = current_user.chief_engineer? ? Team.active : Team.where(id: current_user.team_id)
          teams.or(Team.where(id: @record.team_id)).order(:name)
     end

     # Officers manage subteams of their own team, before and after any change.
     def can_manage?(subteam)
          return true if current_user.chief_engineer?

          [ subteam.team_id, subteam.team_id_in_database ].compact.all?(current_user.team_id)
     end
end
