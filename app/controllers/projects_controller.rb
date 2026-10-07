class ProjectsController < OrganizationRecordsController
     private

     def model_class
          Project
     end

     def parent_field
          :subteam_id
     end

     def parent_options
          Subteam.active.where(team_id: team_ids_for_choices).includes(:team).sort_by(&:full_name)
     end

     def team_id_for(project)
          project.subteam&.team_id
     end
end
