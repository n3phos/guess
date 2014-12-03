

class IRC

  @@instance = RubyChat::IrcHandler.new
  #@@instance = RubyChat::IrcHandler.new
  Room.new(@@instance).create("lobby")

  def self.handler
    @@instance
  end

  def initialize

  end

end
