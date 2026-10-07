class Project < ApplicationRecord
     include Archivable

     belongs_to :subteam
     has_many :tasks, dependent: :restrict_with_error

     delegate :team, to: :subteam

     validates :name, presence: true, uniqueness: { scope: :subteam_id, case_sensitive: false }

     # "Team · Subteam · Project", since names repeat across teams and subteams.
     def full_name
          "#{team.name} · #{subteam.name} · #{name}"
     end
end
