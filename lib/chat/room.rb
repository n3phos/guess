require 'json'

class Room

  # Room class implements a resource like interface for the room
  # controller to create and find chat rooms. It provides the methods
  # for User Model objects to join or leave a specific room.

  attr_accessor :name, :irc_handler, :channel, :room_operator, :users, :active_game, :bot_id

  @@room_list = {}
  @@room_ids = 0

  # returns room instance
  def self.find(id)
    @@room_list[id.to_sym]
  end

  # all rooms
  def self.all
    @@room_list.values
  end


  def initialize(handler)
    self.name = ""
    self.irc_handler = handler
    self.users = {}
    self.active_game = nil
    self.bot_id = nil
  end

  def create(name)
    room_id = alloc_room_id

    self.name = name || room_id
    self.channel = "#tg-#{room_id}"
    self.room_operator = "RoomOp-#{@@room_ids}"

    config = { 'channel' => channel , 'nick' => room_operator}

    # creates irc bot on server side and assigns bot id
    self.bot_id = irc_handler.create_bot(config)

    # append to room list
    append(self)
  end

  def setup_game(game_opts)
    irc_handler.setup_game(bot_id, game_opts)
  end

  def game_info()
    irc_handler.game_info(bot_id)
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
    left = users.delete(irc_nick)

    if(left)
      puts "user #{irc_nick} left"
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

  def append(room)
    id = room.name.to_sym
    return false if @@room_list.keys.include?(id)
    @@room_list.merge!({ id => room })
  end

  def alloc_room_id
    @@room_ids += 1
    return "room##{@@room_ids}"
  end

end

