# An append-only record of a change to a task (who, what, when).
class TaskEvent < ApplicationRecord
     belongs_to :task
     belongs_to :actor, class_name: "User", optional: true
     # The member who was assigned or removed, for assignment events.
     belongs_to :subject_user, class_name: "User", optional: true

     validates :action, presence: true

     def readonly?
          persisted?
     end

     def actor_name
          actor&.name || "System"
     end

     def description
          case action
          when "status_changed"
               "changed the status from #{from_status.humanize} to #{to_status.humanize}"
          when "assigned"
               "assigned #{subject_user.name}"
          else
               "removed #{subject_user.name}"
          end
     end
end
