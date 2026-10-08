class DashboardController < ApplicationController
     include TaskFiltering

     before_action :require_sign_in
     before_action :ensure_leader

     def index
          @projects = Project.active.includes(subteam: :team).sort_by(&:full_name)
          project = Project.find_by(id: params[:project_id])
          @summary = DashboardSummary.new(user: current_user, project: project, filter: task_filter,
                                          from: params[:from], to: params[:to])
     end

     private

     def ensure_leader
          return if current_user.leader?

          redirect_to tasks_path, alert: "Team progress is available to team officers and the Chief Engineer."
     end
end
