class ChangeCategoryColumnType < ActiveRecord::Migration
  def change
    change_column :themes, :category, :integer
    rename_column :themes, :category, :category_id
  end
end
