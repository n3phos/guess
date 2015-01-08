class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :gamerecords, :current, :active
  end
end
