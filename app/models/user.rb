class User < ApplicationRecord
     # These accessors preserve the KAN-9/People interface. Their persisted facts
     # live exclusively in team_memberships and subteam_memberships.
     attr_accessor :team, :subteam
     attr_reader :role
     has_one :active_team_membership, -> { active.order(:id) }, class_name: "TeamMembership"
     after_find :load_membership_identity
     after_initialize -> { @role ||= (chief_engineer? ? "chief_engineer" : "member") }

     scope :in_teams, ->(ids) { where(id: TeamMembership.active.where(team_id: ids).select(:user_id)) }
     scope :in_subteam, ->(id) { where(id: TeamMembership.active.joins(:subteam_memberships).merge(SubteamMembership.active).where(subteam_memberships: { subteam_id: id }).select(:user_id)) }
     scope :without_subteam, -> { where.not(id: TeamMembership.active.joins(:subteam_memberships).merge(SubteamMembership.active).select(:user_id)) }
     # Google-only people have no password; practice accounts still use one.
     has_secure_password validations: false

     has_many :task_assignments, dependent: :destroy
     has_many :assigned_tasks, through: :task_assignments, source: :task
     has_many :time_entries, dependent: :restrict_with_error
     has_many :created_tasks, class_name: "Task", foreign_key: :creator_id,
                              inverse_of: :creator, dependent: :restrict_with_error

     enum :global_role, { participant: 0, chief_engineer: 2 }, validate: true
     scope :member, -> { participant.where(id: TeamMembership.active.member.select(:user_id)) }
     scope :officer, -> { participant.where(id: TeamMembership.active.officer.select(:user_id)) }
     validates :role, inclusion: { in: %w[member officer chief_engineer] }

     ROLE_LABELS = { "member" => "Member", "officer" => "Officer", "chief_engineer" => "Chief Engineer" }.freeze
     ROLES_WITH_ARTICLE = { "member" => "a Member", "officer" => "an Officer",
                            "chief_engineer" => "a Chief Engineer" }.freeze

     has_many :team_memberships, dependent: :restrict_with_error
     has_many :subteam_memberships, through: :team_memberships
     after_save :record_primary_membership

     before_validation :normalize_email
     before_update :preserve_last_active_chief_engineer

     validates :name, presence: true
     validates :email, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :team, presence: true, unless: :chief_engineer?
     validate :subteam_belongs_to_team

     def role=(value)
          @role = value.to_s
          self.global_role = @role == "chief_engineer" ? :chief_engineer : :participant
     end

     def member?
          role == "member"
     end

     def officer?
          role == "officer"
     end

     def team_id
          team&.id
     end

     def team_id=(value)
          self.team = Team.find_by(id: value)
     end

     def subteam_id
          subteam&.id
     end

     def subteam_id=(value)
          self.subteam = Subteam.find_by(id: value)
     end

     def reload(...)
          super.tap { load_membership_identity }
     end

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

     def load_membership_identity
          membership = active_team_membership
          @team = membership&.team
          @subteam = membership&.subteam_memberships&.active&.first&.subteam
          @role = chief_engineer? ? "chief_engineer" : (membership&.role || "member")
     end

     # Keep KAN-9's primary class/role interface while memberships retain join/end dates.
     # One active subteam is the initial customer policy; task assignments are independent.
     def record_primary_membership
          team_memberships.active.where.not(team_id: team_id).find_each do |membership|
               membership.update!(ended_at: Time.current)
          end
          return if team.nil?

          membership = team_memberships.find_or_initialize_by(team: team)
          membership.update!(role: officer? ? :officer : :member, joined_at: membership.joined_at || Time.current, ended_at: nil)
          membership.subteam_memberships.active.where.not(subteam_id: subteam_id).update_all(ended_at: Time.current)
          return if subteam.nil?

          entry = membership.subteam_memberships.find_or_initialize_by(subteam: subteam)
          entry.update!(joined_at: entry.joined_at || Time.current, ended_at: nil)
     end

     def preserve_last_active_chief_engineer
          return unless global_role_in_database == "chief_engineer" && access_revoked_at_in_database.nil?
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
