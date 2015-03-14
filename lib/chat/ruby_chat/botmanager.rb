
require 'bot'

module RubyChat

  class BotManager

    def initialize(irc_handler)
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

    def add(bot)


      self.container.merge!(bot)


    end

    def remove

    end

    def [](key)

      bot = container[key.to_sym]
      return bot[:inst]

    end


    attr_accessor :container

  end


end
