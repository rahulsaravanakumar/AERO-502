class AddDatesAndLinksToTasks < ActiveRecord::Migration[8.1]
     def up
          add_column :tasks, :start_date, :date
          execute <<~SQL.squish
               UPDATE tasks
               SET due_date = COALESCE(due_date, created_at::date),
                   start_date = LEAST(created_at::date, COALESCE(due_date, created_at::date))
          SQL
          change_column_null :tasks, :start_date, false
          change_column_null :tasks, :due_date, false

          create_table :task_links do |t|
               t.references :task, null: false, foreign_key: true
               t.string :url, null: false
               t.integer :position, null: false, default: 0
               t.timestamps
          end
          execute <<~SQL.squish
               INSERT INTO task_links (task_id, url, position, created_at, updated_at)
               SELECT id, link_url, 0, NOW(), NOW() FROM tasks WHERE COALESCE(link_url, '') <> ''
          SQL
          remove_column :tasks, :link_url
     end

     def down
          add_column :tasks, :link_url, :string
          execute <<~SQL.squish
               UPDATE tasks SET link_url = (
                    SELECT url FROM task_links WHERE task_links.task_id = tasks.id ORDER BY position LIMIT 1
               )
          SQL
          drop_table :task_links
          change_column_null :tasks, :due_date, true
          remove_column :tasks, :start_date
     end
end
