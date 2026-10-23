class Team < ApplicationRecord
     include Archivable

     has_many :subteams, dependent: :restrict_with_error
     has_many :projects, dependent: :restrict_with_error
     has_many :team_memberships, dependent: :restrict_with_error
     has_many :users, through: :team_memberships
     has_many :tasks, through: :projects

     validates :name, presence: true, uniqueness: { case_sensitive: false }

     def full_name
          name
     end
end
