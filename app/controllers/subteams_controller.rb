class SubteamsController < OrganizationRecordsController
     def show
          @record = Subteam.find(params[:id])
          @tasks = @record.tasks.includes(:time_entries, :project, :assignees).order(:due_date, :title)
          @members = User.member.in_subteam(@record.id).order(:name)
          filter = TaskFilter.new(params.fetch(:filter, ActionController::Parameters.new).permit(:project_id).to_h.merge("team_id" => @record.team_id))
          @roster_report = TaskReport.new(user: current_user, filter: filter, from: params[:from], to: params[:to])
          @candidates = User.member.in_teams(@record.team_id).without_subteam.where(access_revoked_at: nil).order(:name)
          render "organization/record"
     end

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
