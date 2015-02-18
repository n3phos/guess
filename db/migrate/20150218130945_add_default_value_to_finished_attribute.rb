class AddDefaultValueToFinishedAttribute < ActiveRecord::Migration
  def change
  end

  def self.up
    execute "ALTER TABLE games DROP COLUMN default"
  end
end
