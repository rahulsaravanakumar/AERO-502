# An append-only record of a change to a task (who, what, when).
class TaskEvent < ApplicationRecord
     belongs_to :task
     belongs_to :actor, class_name: "User", optional: true

     validates :action, presence: true

     def readonly?
          persisted?
     end
end
