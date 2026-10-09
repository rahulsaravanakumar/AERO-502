class CreateTaskEvents < ActiveRecord::Migration[8.1]
     def change
          create_table :task_events do |t|
               t.references :task, null: false, foreign_key: true
               t.references :actor, foreign_key: { to_table: :users }
               t.string :action, null: false
               t.string :from_status
               t.string :to_status
               t.datetime :created_at, null: false
          end
          add_index :task_events, %i[task_id created_at]
     end
end
