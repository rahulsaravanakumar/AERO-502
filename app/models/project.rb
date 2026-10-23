class Project < ApplicationRecord
     include Archivable

     attr_readonly :team_id
     belongs_to :team
     has_many :project_subteams, dependent: :restrict_with_error
     has_many :subteams, through: :project_subteams
     has_many :tasks, through: :project_subteams
     validates :name, presence: true, uniqueness: { scope: :team_id, case_sensitive: false }

     def full_name
          "#{team.name} · #{name}"
     end
end
