
require 'client'
require 'game'

module RubyChat

  class Bot < RubyChat::Client

    attr_accessor :cli
    attr_accessor :thread
    attr_accessor :id
    attr_accessor :channel, :game
    attr_accessor :channel_users


    def initialize(config)
      self.channel_users = {}
      self.game = Game.new(self)

      config.merge!({ 'host' => "irc.themeguess.com", 'port' => 6667 })

      chost       = config['host']
      cport       = config['port']
      nick_name   = config['nick']
      self.channel     = config['channel']

      callbacks = Proc.new do

        host chost
        port cport

        on(:connect) do
          nick(nick_name)
        end

        on(:nick) do
          join(channel)
        end

        on(:join) do |nick|
          game.users.update(nick)
        end

        on(:quit) do |nick|
          remove = true
          game.users.update(nick, remove)
        end

        on(:message) do |source, target, message|
          if game.active?
            game.handle_message(source, target, message)
          end
        end
      end

      super({}, &callbacks)

      Bot.init_reply_callbacks

      start

    end

    def setup_game(payload)
      puts "setting up game.."

      self.game.setup(payload)
    end

    def game_info
      game.info
    end

    def start
      self.thread = Thread.new do

        begin
          puts "running thread..."
          self.run

        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end

      end
    end

  end
end

