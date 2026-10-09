class TimeEntriesController < ApplicationController
     before_action :require_sign_in
     before_action :set_own_entry, only: %i[edit update destroy]

     def create
          task = Task.find(params[:task_id])
          unless current_user.can_work_on?(task)
               return deny_access("You can record hours only on tasks assigned to you.")
          end

          entry = task.time_entries.new(time_entry_params)
          entry.user = current_user

          if save_within_daily_limit(entry)
               redirect_to task, notice: "Hours were recorded."
          else
               redirect_to task, alert: entry.errors.full_messages.to_sentence
          end
     end

     def edit
     end

     def update
          @time_entry.assign_attributes(time_entry_params)

          if save_within_daily_limit(@time_entry)
               redirect_to @time_entry.task, notice: "Hours were updated."
          else
               render :edit, status: :unprocessable_entity
          end
     end

     def destroy
          @time_entry.destroy!
          redirect_to @time_entry.task, notice: "Hours entry was removed."
     end

     private

     def set_own_entry
          @time_entry = TimeEntry.find(params[:id])
          return if @time_entry.user_id == current_user.id

          deny_access("You can change only your own hours.")
     end

     # Lock the member's row so concurrent saves cannot exceed the daily limit.
     def save_within_daily_limit(entry)
          current_user.with_lock { entry.save }
     end

     def time_entry_params
          params.require(:time_entry).permit(:hours, :note, :worked_on)
     end
end
