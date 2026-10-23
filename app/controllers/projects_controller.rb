class ProjectsController < OrganizationRecordsController
     def new
          @record = Project.new(team_id: params[:team_id])
          return deny_organization_access unless can_start?(@record)

          render "organization/form"
     end

     def create
          @record = Project.new(project_params.except(:subteam_ids))
          return deny_organization_access unless can_manage?(@record)

          save_project("created")
     end

     def update
          @record.assign_attributes(project_params.slice(:name))
          save_project("updated")
     end

     private

     def model_class
          Project
     end

     def parent_field
          :team_id
     end

     def parent_options
          Team.where(id: team_ids_for_choices).order(:name)
     end

     def team_id_for(project)
          project.team_id
     end

     def project_params
          params.require(:project).permit(:name, :team_id, subteam_ids: [])
     end

     def save_project(verb)
          ids = project_params.key?(:subteam_ids) ? project_params[:subteam_ids].reject(&:blank?).map(&:to_i).uniq : @record.subteam_ids
          selected = Subteam.where(id: ids, team_id: @record.team_id)
          @record.valid?
          @record.errors.add(:subteams, "must include at least one subteam from the project's team") if ids.empty? || selected.count != ids.size
          removed = @record.project_subteams.where.not(subteam_id: ids)
          @record.errors.add(:subteams, "cannot remove a subteam with recorded tasks") if removed.joins(:tasks).exists?
          if @record.errors.any?
               @selected_subteam_ids = ids
               return render "organization/form", status: :unprocessable_entity
          end

          Project.transaction do
               @record.save!
               removed.each(&:destroy!)
               selected.each { |subteam| @record.project_subteams.find_or_create_by!(subteam: subteam) }
          end
          redirect_to organization_path, notice: "Project “#{@record.name}” was #{verb}."
     end
end
