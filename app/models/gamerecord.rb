class Gamerecord < ActiveRecord::Base

  after_create :create_history

  belongs_to :game
  belongs_to :theme

  has_one :history

  def self.build_records(game, themes)

    themes.each do |t|
      self.create :game_id => game.id, :theme_id => t.id, :active => false
    end

  end

  def create_history
    History.create :gamerecord_id => self.id
  end



end
