class ProjectsController < OrganizationRecordsController
     private

     def model_class
          Project
     end

     def parent_field
          nil
     end
end
