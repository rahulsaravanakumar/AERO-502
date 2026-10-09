class TimelinesController < ApplicationController
     include TaskFiltering

     before_action :require_sign_in
     before_action :ensure_leader

     def show
          tasks = task_filter.apply(Task.accessible_to(current_user)).includes(:team, :subteam, :assignees).to_a
          @timeline = TaskTimeline.new(tasks: tasks, from: params[:from], weeks: params[:weeks])
     end

     private

     def ensure_leader
          return if current_user.leader?

          redirect_to tasks_path, alert: "The timeline is available to team officers and the Chief Engineer."
     end
end
