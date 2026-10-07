class TimeEntry < ApplicationRecord
     MAX_HOURS_PER_DAY = 24

     belongs_to :task
     belongs_to :user

     validates :hours, numericality: { greater_than: 0 }
     validates :worked_on, presence: true
     validate :user_is_assigned
     validate :daily_total_within_limit

     private

     def user_is_assigned
          return if task.blank? || user.blank? || task.assignee_ids.include?(user_id)

          errors.add(:user, "must be assigned to the task")
     end

     # A member's hours across all tasks for one worked date may not exceed 24.
     def daily_total_within_limit
          return if user.blank? || worked_on.blank? || !hours.is_a?(Numeric)

          other_hours = TimeEntry.where(user: user, worked_on: worked_on).where.not(id: id).sum(:hours)
          total = other_hours + hours
          return if total <= MAX_HOURS_PER_DAY

          errors.add(:hours, "for #{worked_on.to_fs(:long)} would total " \
                             "#{total.to_s("F").delete_suffix(".0")}; a member can record at most " \
                             "#{MAX_HOURS_PER_DAY} hours per day")
     end
end
