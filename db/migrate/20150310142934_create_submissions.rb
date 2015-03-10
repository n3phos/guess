class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :theme_id

      t.timestamps
    end
  end
end
