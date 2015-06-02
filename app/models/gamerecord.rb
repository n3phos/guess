class Gamerecord < ActiveRecord::Base

  after_create :create_history

  belongs_to :game
  belongs_to :theme

  has_one :history

  def create_history
    History.create :gamerecord_id => self.id
  end



end
