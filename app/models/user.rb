class User < ActiveRecord::Base
  after_initialize :init
  after_create :init

  validates :nick, :uniqueness => {:message => "has already been taken"},
                   :format => {:with => /\A[a-zA-Z0-9\-_]+\z/,
                               :message => "Your nickname should contain only these characters: a-z, A-Z, 0-9, -_ "},
                   :length => { maximum: 12,
                                too_long: "is too long (maximum is %{count} characters)" }



  def init
    self.irc_nick = "tgu-#{self.id}"
  end
end
