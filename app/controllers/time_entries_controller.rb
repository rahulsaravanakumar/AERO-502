class TimeEntriesController < ApplicationController
     before_action :require_sign_in

     def create
          task = Task.find(params[:task_id])
          unless current_user.can_work_on?(task)
               return deny_access("You can record hours only on tasks assigned to you.")
          end

          entry = task.time_entries.new(time_entry_params)
          entry.user = current_user

          if entry.save
               redirect_to task, notice: "Hours were recorded."
          else
               redirect_to task, alert: entry.errors.full_messages.to_sentence
          end
     end

     private

     def time_entry_params
          params.require(:time_entry).permit(:hours, :note, :worked_on)
     end
end
