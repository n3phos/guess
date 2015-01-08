class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.integer :gamerecord_id
      t.string :media_resolver
      t.string :theme_resolver
      t.string :interpret_resolver

      t.timestamps
    end
  end
end
