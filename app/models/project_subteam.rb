class ProjectSubteam < ApplicationRecord
     attr_readonly :project_id, :subteam_id
     belongs_to :project
     belongs_to :subteam
     has_many :tasks, dependent: :restrict_with_error

     validates :subteam_id, uniqueness: { scope: :project_id }
     validate :same_team

     private

     def same_team
          return if project.nil? || subteam.nil? || project.team_id == subteam.team_id

          errors.add(:subteam, "must belong to the project's team")
     end
end
