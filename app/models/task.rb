class Task < ApplicationRecord
     LINK_FORMAT_MESSAGE = "must each be a full web address starting with http:// or https://".freeze

     belongs_to :project
     belongs_to :team
     belongs_to :subteam, optional: true
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

     attribute :start_date, :date, default: -> { Date.current }

     validates :title, :start_date, :due_date, presence: true
     validates :estimated_hours, numericality: { greater_than_or_equal_to: 0 }
     validates :status, presence: true
     validate :subteam_belongs_to_team
     validate :due_date_not_before_start_date
     validate :reference_links_are_web_addresses

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

     def replace_links
          links.destroy_all
          @reference_urls.each_with_index { |url, position| links.create!(url: url, position: position) }
          @reference_urls = nil
          links.reset
     end
end
