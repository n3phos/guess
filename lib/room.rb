
class Room

  attr_accessor :name, :id, :handler

  def initialize(irc_handler)
    self.name = ""
    self.id = nil
    self.handler = irc_handler
  end

  def create(config)
    cli = self.handler.clusters[:virgo].cli
    cli.create_bot(config)
  end

end

