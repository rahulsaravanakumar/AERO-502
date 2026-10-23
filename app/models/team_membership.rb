class TeamMembership < ApplicationRecord
     belongs_to :user
     belongs_to :team
     has_many :subteam_memberships, dependent: :restrict_with_error
     enum :role, { member: 0, officer: 1 }, validate: true
     scope :active, -> { where(ended_at: nil) }
     validates :user_id, uniqueness: { scope: :team_id }
     validates :joined_at, presence: true
     before_update :end_subteam_memberships, if: :ended_at_changed?

     private

     def end_subteam_memberships
          return if ended_at.nil?

          subteam_memberships.active.update_all(ended_at: ended_at)
     end
end
