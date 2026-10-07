class User < ApplicationRecord
     belongs_to :team, optional: true
     has_secure_password

     has_many :task_assignments, dependent: :destroy
     has_many :assigned_tasks, through: :task_assignments, source: :task
     has_many :time_entries, dependent: :restrict_with_error
     has_many :created_tasks, class_name: "Task", foreign_key: :creator_id,
                              inverse_of: :creator, dependent: :restrict_with_error

     enum :role, { member: 0, officer: 1, chief_engineer: 2 }, validate: true

     ROLE_LABELS = { "member" => "Member", "officer" => "Officer", "chief_engineer" => "Chief Engineer" }.freeze
     ROLES_WITH_ARTICLE = { "member" => "a Member", "officer" => "an Officer",
                            "chief_engineer" => "a Chief Engineer" }.freeze

     before_validation :normalize_email

     validates :name, presence: true
     validates :email, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :team, presence: true, unless: :chief_engineer?

     def role_label
          ROLE_LABELS.fetch(role)
     end

     def role_with_article
          ROLES_WITH_ARTICLE.fetch(role)
     end

     def leader?
          officer? || chief_engineer?
     end

     def can_manage?(task)
          chief_engineer? || (officer? && task.team_id == team_id)
     end

     def can_work_on?(task)
          task.assignee_ids.include?(id)
     end

     private

     def normalize_email
          self.email = email.to_s.strip.downcase
     end
end
