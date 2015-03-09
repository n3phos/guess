class CreateThemeQuestions < ActiveRecord::Migration
  def change
    create_table :theme_questions do |t|
      t.integer :theme_id
      t.integer :question_id

      t.timestamps
    end
  end
end
