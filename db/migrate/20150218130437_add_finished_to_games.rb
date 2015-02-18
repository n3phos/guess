class AddFinishedToGames < ActiveRecord::Migration
  def change
    add_column :games, :finished, :boolean
    add_column :games, :default, :false
  end
end
