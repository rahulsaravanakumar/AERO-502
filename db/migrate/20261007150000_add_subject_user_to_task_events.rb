class AddSubjectUserToTaskEvents < ActiveRecord::Migration[8.1]
     def change
          add_reference :task_events, :subject_user, foreign_key: { to_table: :users }
     end
end
