class TaskAssignment < ApplicationRecord
     belongs_to :task
     belongs_to :user

     validates :user_id, uniqueness: { scope: :task_id }
     validate :assignee_belongs_to_task_team

     private

     def assignee_belongs_to_task_team
          return if task.blank? || user.blank? || user.team_id == task.team_id

          errors.add(:user, "must belong to the task's team")
     end
end
