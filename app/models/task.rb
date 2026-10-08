class Task < ApplicationRecord
     LINK_FORMAT_MESSAGE = "must each be a full web address starting with http:// or https://".freeze

     # The project decides the task's subteam and team (scope S01/S03).
     belongs_to :project
     belongs_to :team
     belongs_to :subteam
     belongs_to :creator, class_name: "User", inverse_of: :created_tasks

     has_many :task_assignments, dependent: :destroy
     has_many :assignees, through: :task_assignments, source: :user
     has_many :time_entries, dependent: :destroy
     has_many :links, -> { order(:position, :id) }, class_name: "TaskLink", dependent: :destroy,
                                                    inverse_of: :task
     has_many :events, class_name: "TaskEvent", dependent: :delete_all

     enum :status, { backlog: 0, in_progress: 1, completed: 2 }, validate: true

     # The signed-in user making a change, recorded on the task's history.
     attr_accessor :acting_user
     # Set for officers: the task's project must belong to this team.
     attr_accessor :allowed_team_id

     attribute :start_date, :date, default: -> { Date.current }

     validates :title, :start_date, :due_date, presence: true
     validates :estimated_hours, numericality: { greater_than_or_equal_to: 0 }
     validates :status, presence: true
     validate :project_in_allowed_team
     validate :due_date_not_before_start_date
     validate :reference_links_are_web_addresses

     before_validation :copy_groups_from_project

     after_save :replace_links, if: -> { @reference_urls }
     after_update :record_status_change, if: :saved_change_to_status?

     scope :accessible_to, lambda { |user|
          if user.chief_engineer?
               all
          elsif user.officer?
               where(team_id: user.team_id)
          else
               joins(:task_assignments).where(task_assignments: { user_id: user.id })
          end
     }

     def reference_links_text
          (@reference_urls || links.map(&:url)).join("\n")
     end

     def reference_links_text=(text)
          @reference_urls = text.to_s.split(/\r?\n/).map(&:strip).compact_blank
     end

     # Replaces the assignees and records who was assigned or removed, and by whom.
     def assign_members(user_ids, actor:)
          previous_ids = assignee_ids
          self.assignee_ids = user_ids
          (user_ids.map(&:to_i) - previous_ids).each { |id| record_assignment("assigned", id, actor) }
          (previous_ids - user_ids.map(&:to_i)).each { |id| record_assignment("unassigned", id, actor) }
     end

     # Unfinished and past its due date.
     def overdue?
          !completed? && due_date < Date.current
     end

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

     def copy_groups_from_project
          return if project.nil?

          self.subteam = project.subteam
          self.team = subteam.team
     end

     def project_in_allowed_team
          return if allowed_team_id.nil? || team_id == allowed_team_id

          errors.add(:project, "must belong to your team")
     end

     def due_date_not_before_start_date
          return if start_date.blank? || due_date.blank? || due_date >= start_date

          errors.add(:due_date, "must be on or after the start date")
     end

     def reference_links_are_web_addresses
          return if Array(@reference_urls).all? { |url| web_address?(url) }

          errors.add(:reference_links_text, LINK_FORMAT_MESSAGE)
     end

     def web_address?(url)
          uri = URI.parse(url)
          uri.is_a?(URI::HTTP) && uri.host.present?
     rescue URI::InvalidURIError
          false
     end

     def record_status_change
          from_status, to_status = saved_change_to_status
          TaskEvent.create!(task: self, actor: acting_user, action: "status_changed",
                            from_status: from_status, to_status: to_status)
     end

     def record_assignment(action, user_id, actor)
          TaskEvent.create!(task: self, actor: actor, action: action, subject_user_id: user_id)
     end

     def replace_links
          links.destroy_all
          @reference_urls.each_with_index { |url, position| links.create!(url: url, position: position) }
          @reference_urls = nil
          links.reset
     end
end
