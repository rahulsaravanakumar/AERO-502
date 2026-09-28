class Subteam < ApplicationRecord
     belongs_to :team
     has_many :tasks, dependent: :nullify

     validates :name, presence: true, uniqueness: { scope: :team_id, case_sensitive: false }
end
