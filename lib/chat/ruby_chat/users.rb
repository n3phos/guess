
class User < Hash

  module GameUser

    def ready?
      self['ready']
    end

    def reset
      self['ready'] = false
    end

    def ready
      self['ready'] = true
    end
  end

  include GameUser

  def initialize
  end

end

class Users

  attr_accessor :game
  attr_accessor :users

  def initialize(game)
    self.users = {}
    self.game = game
  end

  def [](key)
    self.users[key]
  end

  def are_ready?
    self.users.all? do |k, u|
      u.ready?
    end
  end

  def update(usr, remove = false)
    # provide callback
    return if ! before_update(usr)

    if ! remove
      add(usr)
    else
      remove(usr)
    end
  end

  def reset
    each do |u|
      u.reset
    end
  end

  def before_update(usr)
    usr.match(/tgu/) ? true : false
  end

  def all_removed
    game.no_users
  end

  def each
    users.each do |k, u|
      yield(u)
    end
  end

  protected

  def add(u)
    self.users.merge!({ u.to_sym => User.new })
  end

  def remove(u)
    u = u.to_sym

    users.delete(u)
    all_removed if users.empty?
  end
end

