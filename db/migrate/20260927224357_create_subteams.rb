class CreateSubteams < ActiveRecord::Migration[8.0]
  def change
    create_table :subteams do |t|
      t.string :name, null: false
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    add_index :subteams, [ :team_id, :name ], unique: true
  end
end
