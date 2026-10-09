class Subteam < ApplicationRecord
     include Archivable

     belongs_to :team
     has_many :projects, dependent: :restrict_with_error
     has_many :tasks, dependent: :restrict_with_error
     has_many :users, dependent: :nullify

     validates :name, presence: true, uniqueness: { scope: :team_id, case_sensitive: false }

     # "Team · Subteam", since subteam names repeat across teams.
     def full_name
          "#{team.name} · #{name}"
     end
end
