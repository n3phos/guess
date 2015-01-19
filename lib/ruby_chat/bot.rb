
require 'client'
require 'game'

module RubyChat

  class Bot < RubyChat::Client

    attr_accessor :word_list
    attr_accessor :cli
    attr_accessor :thread
    attr_accessor :id
    attr_accessor :channel, :game
    attr_accessor :channel_users


    def initialize(config)

      self.channel_users = {}

      self.game = Game.new(self)

      puts "bot initialize"

      #self.id = config['id']
      self.word_list = []

      config.merge!({ 'host' => "128.199.35.15", 'port' => 6667 })


      chost       = config['host']
      cport       = config['port']
      nick_name   = config['nick']
      channel     = config['channel']

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

          puts "on join callback"

          update_users(nick)


        end


        on(:quit) do |nick|

          remove = true
          update_users(nick, remove)

        end

        #on(:raw) do |m|
        #  puts "raw: #{m.inspect}"
        #end


        on(:message) do |source, target, message|

          if game.active?
            handle_message(source, target, message)
          end

        end

      end

      puts "before super in bot"
      super({}, &callbacks)

      Bot.init_reply_callbacks

      start

    end

    def setup_game(payload)

      puts "setting up game.."

      self.game.setup(payload)

    end

    def handle_message(source, target, message)

      begin
        e = parse_event(source, message)
        puts "dispatching event: #{e.inspect}"
        game.dispatch_event(e)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      else
        # other exception
      ensure
        # always executed
      end



    end

    def parse_event(s, m)
      puts "in parse event"
      event = {
        'trigger' => "",
        'source' => "",
        'data' => ""
      }

      if m.match(/^!/)
         event['trigger'] = m.gsub(/^!/, "")
         event['source'] = s
      end

      if event['trigger'].empty?
        event['trigger'] = "guess"
        event['source'] = s
        event['data'] = m
      end

      puts "after parse event"

      return event
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

    def update_users(usr, remove = false)

      puts "in update users"

      return unless usr.match(/tgu/)


      if !remove
        add_user(usr)
      else
        remove_user(usr)
      end

      puts "#{self.channel_users.inspect}"

    end

    def add_user(u)
      self.channel_users.merge!({ u.to_sym => { 'ready' => false } })
    end

    def remove_user(u)
      puts "in delete user"
      self.channel_users.delete(u.to_sym)
    end

    def parse_users(usr)


      cusers = usr.split(" ")

      cusers = cusers.select do |u|
        u.match(/tgu/)
      end

      cusers

    end


  end
end

#config = { 'nick' => 'wtf' , 'channel' => "#nephos" }
#bot = RubyChat::Bot.new(config)
