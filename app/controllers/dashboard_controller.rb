class DashboardController < ApplicationController
     before_action :require_sign_in

     def index
          @tasks = Task.accessible_to(current_user)
                       .includes(:project, :team, :assignees, :time_entries)
                       .order(:due_date, :title)
          @status_counts = Task.accessible_to(current_user).group(:status).count
          @member_totals = TimeEntry.joins(:task)
                                    .merge(Task.accessible_to(current_user))
                                    .group(:user_id)
                                    .sum(:hours)
     end
end
