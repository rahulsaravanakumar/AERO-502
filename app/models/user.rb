class User < ApplicationRecord
     belongs_to :team, optional: true
     belongs_to :subteam, optional: true
     # Google-only people have no password; practice accounts still use one.
     has_secure_password validations: false

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
     before_update :preserve_last_active_chief_engineer

     validates :name, presence: true
     validates :email, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :team, presence: true, unless: :chief_engineer?
     validate :subteam_belongs_to_team

     def role_label
          ROLE_LABELS.fetch(role)
     end

     def role_with_article
          ROLES_WITH_ARTICLE.fetch(role)
     end

     def access_revoked?
          access_revoked_at.present?
     end

     # Password sign-in for practice accounts; Google-only people have no password.
     def authenticate_password_sign_in(password)
          password_digest.present? && authenticate(password)
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

     def preserve_last_active_chief_engineer
          return unless role_in_database == "chief_engineer" && access_revoked_at_in_database.nil?
          return if chief_engineer? && !access_revoked?

          # Serialize administrator removals across requests. This PostgreSQL lock
          # lasts until the save transaction commits or rolls back, so two chiefs
          # cannot simultaneously remove the organization's last administrators.
          self.class.connection.execute("SELECT pg_advisory_xact_lock(260026)")
          return if self.class.chief_engineer.where(access_revoked_at: nil).where.not(id: id).exists?

          errors.add(:base, "At least one active Chief Engineer is required. Add another Chief Engineer before removing this role or access.")
          throw :abort
     end

     def subteam_belongs_to_team
          return if subteam.blank? || subteam.team_id == team_id

          errors.add(:subteam, "must belong to the person's team")
     end

     def normalize_email
          self.email = email.to_s.strip.downcase
     end
end
