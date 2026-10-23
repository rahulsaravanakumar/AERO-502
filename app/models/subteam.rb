class Subteam < ApplicationRecord
     include Archivable

     belongs_to :team
     has_many :project_subteams, dependent: :restrict_with_error
     has_many :projects, through: :project_subteams
     has_many :subteam_memberships, dependent: :restrict_with_error
     has_many :tasks, through: :project_subteams
     has_many :users, through: :subteam_memberships

     validates :name, presence: true, uniqueness: { scope: :team_id, case_sensitive: false }

     # "Team · Subteam", since subteam names repeat across teams.
     def full_name
          "#{team.name} · #{name}"
     end
end
