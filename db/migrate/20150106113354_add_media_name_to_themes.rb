class AddMediaNameToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :media_name, :string
  end
end
