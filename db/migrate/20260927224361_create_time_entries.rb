class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :hours, precision: 7, scale: 2, null: false
      t.string :note
      t.date :worked_on, null: false

      t.timestamps
    end
  end
end
