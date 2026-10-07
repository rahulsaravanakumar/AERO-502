class Subteam < ApplicationRecord
     include Archivable

     belongs_to :team
     has_many :tasks, dependent: :nullify
     has_many :users, dependent: :nullify

     validates :name, presence: true, uniqueness: { scope: :team_id, case_sensitive: false }
end
