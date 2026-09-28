class Task < ApplicationRecord
     belongs_to :project
     belongs_to :team
     belongs_to :subteam, optional: true
     belongs_to :creator, class_name: "User", inverse_of: :created_tasks

     has_many :task_assignments, dependent: :destroy
     has_many :assignees, through: :task_assignments, source: :user
     has_many :time_entries, dependent: :destroy

     enum :status, { backlog: 0, in_progress: 1, completed: 2 }

     validates :title, presence: true
     validates :estimated_hours, numericality: { greater_than_or_equal_to: 0 }
     validates :status, presence: true
     validates :link_url, format: {
          with: %r{\Ahttps?://[^\s]+\z},
          message: "must start with http:// or https://"
     }, allow_blank: true
     validate :subteam_belongs_to_team

     scope :accessible_to, lambda { |user|
          if user.chief_engineer?
               all
          elsif user.officer?
               where(team_id: user.team_id)
          else
               joins(:task_assignments).where(task_assignments: { user_id: user.id })
          end
     }

     def total_actual_hours
          return time_entries.sum(&:hours) if time_entries.loaded?

          time_entries.sum(:hours)
     end

     def actual_hours_for(user)
          return time_entries.select { |entry| entry.user_id == user.id }.sum(&:hours) if time_entries.loaded?

          time_entries.where(user: user).sum(:hours)
     end

     def variance_hours
          total_actual_hours - estimated_hours
     end

     private

     def subteam_belongs_to_team
          return if subteam.blank? || subteam.team_id == team_id

          errors.add(:subteam, "must belong to the selected team")
     end
end
