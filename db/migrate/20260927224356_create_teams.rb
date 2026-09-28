class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :teams, [ :project_id, :name ], unique: true
  end
end
