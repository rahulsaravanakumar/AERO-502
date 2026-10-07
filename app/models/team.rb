class Team < ApplicationRecord
     include Archivable

     has_many :subteams, dependent: :restrict_with_error
     has_many :projects, through: :subteams
     has_many :users, dependent: :nullify
     has_many :tasks, dependent: :restrict_with_error

     validates :name, presence: true, uniqueness: { case_sensitive: false }

     def full_name
          name
     end
end
