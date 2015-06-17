
require 'bot'

module RubyChat

  class BotManager

    def initialize(ipc_serv)
      self.container = {}
    end

    def create(id, config)
      id = id.to_sym
      bot = RubyChat::Bot.new(config)

      bot_hash = {
        id => {
          :inst => bot
        }
      }

      add(bot_hash)
    end

    def [](key)
      bot = container[key.to_sym]
      bot[:inst]
    end

    protected

    def add(bot)
      self.container.merge!(bot)
    end

    def remove(id)
    end

    attr_accessor :container

  end
end
