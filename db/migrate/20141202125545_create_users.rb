class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nick
      t.string :irc_nick

      t.timestamps
    end
  end
end
