class AddDisabledToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :disabled, :boolean, :default => false
  end
end
