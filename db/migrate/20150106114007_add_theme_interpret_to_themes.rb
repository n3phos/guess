class AddThemeInterpretToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :theme_interpret, :string
  end
end
