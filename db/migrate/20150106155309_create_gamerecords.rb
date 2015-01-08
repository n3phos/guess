class CreateGamerecords < ActiveRecord::Migration
  def change
    create_table :gamerecords do |t|
      t.integer :theme_id
      t.integer :game_id
      t.integer :history_id
      t.boolean :current

      t.timestamps
    end
  end
end
