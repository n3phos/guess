class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :video_id
      t.integer :start_seconds
      t.integer :end_seconds
      t.string :image_path

      t.timestamps
    end
  end
end
