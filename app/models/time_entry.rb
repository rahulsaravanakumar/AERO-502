class TimeEntry < ApplicationRecord
     belongs_to :task
     belongs_to :user

     validates :hours, numericality: { greater_than: 0 }
     validates :worked_on, presence: true
     validate :user_is_assigned

     private

     def user_is_assigned
          return if task.blank? || user.blank? || task.assignee_ids.include?(user_id)

          errors.add(:user, "must be assigned to the task")
     end
end
