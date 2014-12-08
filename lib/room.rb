
class Room

  attr_accessor :name, :handler, :channel, :room_operator, :users

  @@container = {}
  @@room_ids = 0

  def self.find(id)
    @@container[id.to_sym]
  end


  def initialize(irc_handler)
    self.name = ""
    self.handler = irc_handler
    self.users = {}
  end

  def create(name)
    room_id = alloc_room_id

    self.name = name || room_id
    self.channel = "#tg-#{room_id}"
    self.room_operator = "RoomOp-#{@@room_ids}"

    config = { 'channel' => channel , 'nick' => room_operator}

    cli = self.handler.clusters[:virgo].cli
    cli.create_bot(config)
    add(self)
  end


  # user model object
  def join(user)
    joined = false

    irc_nick = user.irc_nick.to_sym
    nick = user.nick

    u = { irc_nick => nick }

    users.merge!(u)

    joined = true

  end

  def leave(user)
    left = false

    irc_nick = user.irc_nick.to_sym

    left = users.delete(irc_nick) do |k,v|
      k == irc_nick
    end

    left

  end

  protected

  def add(room)
    puts "in add"
    id = room.name.to_sym
    return false if @@container.keys.include?(id)
    @@container.merge!({ id => room })
    puts @@container
  end

  def alloc_room_id
    @@room_ids += 1
    return "room##{@@room_ids}"
  end

end

