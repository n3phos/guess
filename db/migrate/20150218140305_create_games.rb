class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :history_id
      t.boolean :started, :default => false
      t.boolean :finished, :default => false

      t.timestamps
    end
  end
end
