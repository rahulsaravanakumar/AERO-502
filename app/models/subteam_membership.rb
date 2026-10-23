class SubteamMembership < ApplicationRecord
     belongs_to :team_membership
     belongs_to :subteam
     has_one :user, through: :team_membership
     scope :active, -> { where(ended_at: nil) }
     validates :subteam_id, uniqueness: { scope: :team_membership_id }
     validates :joined_at, presence: true
     validate :same_team

     private

     def same_team
          return if subteam.nil? || team_membership.nil? || subteam.team_id == team_membership.team_id

          errors.add(:subteam, "must belong to the member's class")
     end
end
