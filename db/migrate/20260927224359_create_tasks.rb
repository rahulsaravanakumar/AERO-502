class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.text :instructions
      t.string :link_url
      t.date :due_date
      t.decimal :estimated_hours, precision: 7, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.references :project, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :subteam, null: true, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
