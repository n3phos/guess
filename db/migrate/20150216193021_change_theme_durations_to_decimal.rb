class ChangeThemeDurationsToDecimal < ActiveRecord::Migration
  def change
    change_column :themes, :start_seconds, :decimal
    change_column :themes, :end_seconds, :decimal
  end
end
