require 'json'

class Room

  attr_accessor :name, :handler, :channel, :room_operator, :users, :active_game, :cli

  @@container = {}
  @@room_ids = 0

  def self.find(id)
    @@container[id.to_sym]
  end


  def initialize(irc_handler)
    self.name = ""
    self.handler = irc_handler
    self.users = {}
    self.active_game = nil
  end

  def create(name)
    room_id = alloc_room_id

    self.name = name || room_id
    self.channel = "#tg-#{room_id}"
    self.room_operator = "RoomOp-#{@@room_ids}"

    config = { 'channel' => channel , 'nick' => room_operator}

    self.cli = self.handler.clusters[:virgo].cli
    cli.create_bot(config)
    add(self)
  end

  def setup_game(game_opts)
    cli.setup_bot_game("virgo#bot_1", game_opts)
  end

  def game_info()
    cli.game_info("virgo#bot_1")
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

  def to_json(current_user)

    h = { "name" => name,
          "channel" => channel,
          "room_operator" => room_operator,
          "users" => users,
          "current_user" => { "name" => current_user.nick, "irc_nick" => current_user.irc_nick }
        }

    h.to_json


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

