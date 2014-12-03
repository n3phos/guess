class User < ActiveRecord::Base
  after_initialize :init

  def init
    self.irc_nick = "tguser-#{self.id}"
  end
end
