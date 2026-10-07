class Team < ApplicationRecord
     include Archivable

     belongs_to :project
     has_many :subteams, dependent: :destroy
     has_many :users, dependent: :nullify
     has_many :tasks, dependent: :restrict_with_error

     validates :name, presence: true, uniqueness: { scope: :project_id, case_sensitive: false }
end
