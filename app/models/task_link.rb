class TaskLink < ApplicationRecord
     belongs_to :task

     validates :url, presence: true
end
