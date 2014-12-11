class User < ActiveRecord::Base
  after_initialize :init

  def init
    self.irc_nick = "tgu-#{self.id}"
  end
end
