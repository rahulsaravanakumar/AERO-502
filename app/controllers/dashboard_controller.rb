class DashboardController < ApplicationController
     before_action :require_sign_in
     before_action :ensure_leader

     def index
          @projects = Project.order(:name)
          project = Project.find_by(id: params[:project_id]) || default_project
          @summary = DashboardSummary.new(user: current_user, project: project, from: params[:from], to: params[:to])
     end

     private

     def ensure_leader
          return if current_user.leader?

          redirect_to tasks_path, alert: "The project dashboard is available to team officers and the Chief Engineer."
     end

     # The first project that has tasks, so the dashboard opens on real work.
     def default_project
          Project.where(id: Task.select(:project_id)).order(:name).first || @projects.first
     end
end
