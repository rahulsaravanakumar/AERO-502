class Project < ApplicationRecord
     include Archivable

     has_many :teams, dependent: :destroy
     has_many :tasks, dependent: :restrict_with_error

     validates :name, presence: true, uniqueness: { case_sensitive: false }
end
