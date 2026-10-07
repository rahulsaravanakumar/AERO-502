class TeamsController < OrganizationRecordsController
     private

     def model_class
          Team
     end

     def parent_field
          :project_id
     end

     def parent_options
          Project.active.or(Project.where(id: @record.project_id)).order(:name)
     end
end
