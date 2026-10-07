class TasksController < ApplicationController
     include TaskFiltering

     OWN_TEAM_ONLY = "You can manage only tasks on your own team.".freeze

     before_action :require_sign_in
     before_action :set_task, only: %i[show edit update destroy]
     before_action :ensure_can_view_task, only: :show
     before_action :ensure_leader, only: %i[new create]
     before_action :ensure_can_manage_task, only: %i[edit destroy]

     def index
          @tasks = task_filter.apply(Task.accessible_to(current_user))
                              .includes(:project, :team, :assignees, :time_entries)
                              .order(:status, :due_date, :title)
          @view = params[:view] == "mine" ? "mine" : "board"
          if @view == "mine"
               @tasks = @tasks.joins(:task_assignments)
                              .where(task_assignments: { user_id: current_user.id })
          end
     end

     def show
          @time_entry = TimeEntry.new(worked_on: Date.current)
     end

     def new
          @task = Task.new(status: :backlog)
          prepare_form
     end

     def create
          @task = Task.new(task_params.except(:assignee_ids, :status))
          @task.creator = current_user
          restrict_task_to_officer_team

          if save_task_with_assignments
               redirect_to @task, notice: "Task was created successfully."
          else
               prepare_form
               render :new, status: :unprocessable_entity
          end
     end

     def edit
          prepare_form
     end

     def update
          return update_status_as_member unless current_user.can_manage?(@task)

          @task.assign_attributes(task_params.except(:assignee_ids))
          @task.acting_user = current_user
          restrict_task_to_officer_team

          if save_task_with_assignments
               redirect_to @task, notice: "Task was updated successfully."
          else
               prepare_form
               render :edit, status: :unprocessable_entity
          end
     end

     def destroy
          @task.destroy!
          redirect_to tasks_path, notice: "Task was deleted."
     end

     private

     def set_task
          @task = Task.find(params[:id])
     end

     def ensure_can_view_task
          return if Task.accessible_to(current_user).exists?(@task.id)

          deny_access("You cannot view that task.")
     end

     def ensure_leader
          deny_access unless current_user.leader?
     end

     def ensure_can_manage_task
          deny_access(OWN_TEAM_ONLY) unless current_user.can_manage?(@task)
     end

     def update_status_as_member
          return deny_access(OWN_TEAM_ONLY) if current_user.leader?
          unless current_user.can_work_on?(@task)
               return deny_access("You can update only tasks assigned to you.")
          end

          @task.acting_user = current_user
          if @task.update(params.require(:task).permit(:status))
               redirect_to @task, notice: "Task status was updated."
          else
               @time_entry = TimeEntry.new(worked_on: Date.current)
               render :show, status: :unprocessable_entity
          end
     end

     def task_params
          params.require(:task).permit(
               :title, :description, :instructions, :reference_links_text, :start_date, :due_date,
               :estimated_hours, :status, :project_id, :team_id, :subteam_id,
               assignee_ids: []
          )
     end

     def restrict_task_to_officer_team
          @task.team = current_user.team if current_user.officer?
     end

     # Assignees change only when the form submits them (it always sends the field).
     def save_task_with_assignments
          Task.transaction do
               @task.save!
               if task_params.key?(:assignee_ids)
                    assignee_ids = Array(task_params[:assignee_ids]).reject(&:blank?).uniq
                    @task.assign_members(assignee_ids, actor: current_user)
               end
          end
          true
     rescue ActiveRecord::RecordInvalid => error
          @task.errors.merge!(error.record.errors) unless error.record == @task
          false
     end

     # Everyday lists show active groups, plus the task's current ones when editing.
     def prepare_form
          @projects = Project.active.or(Project.where(id: @task.project_id)).order(:name)
          teams = current_user.chief_engineer? ? Team.all : Team.where(id: current_user.team_id)
          @teams = teams.active.or(teams.where(id: @task.team_id)).order(:name)
          team_ids = @teams.select(:id)
          @subteams = Subteam.where(team_id: team_ids).active.or(Subteam.where(id: @task.subteam_id)).order(:name)
          @assignees = User.member.where(team_id: team_ids).order(:name)
     end
end
