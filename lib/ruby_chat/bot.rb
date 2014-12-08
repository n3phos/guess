

require 'client'

module RubyChat

  class Bot

    attr_accessor :word_list
    attr_accessor :cli
    attr_accessor :thread
    attr_accessor :id

    def initialize(config)

      #self.id = config['id']
      self.word_list = []

      config.merge!({ 'host' => "128.199.35.15", 'port' => 6667 })


      init_client(config)


      self.start

    end

    def feed(list)

    end

    def init_client(config)


      chost       = config['host']
      cport       = config['port']
      nick_name   = config['nick']
      channel     = config['channel']

      self.cli = RubyChat::Client.new do

        host chost
        port cport

        on(:connect) do
          nick(nick_name)
        end

        on(:nick) do
          join(channel)
        end


        on(:message) do |source, target, message|

          message(channel, "hello #{source}, loktar ogar")

        end

      end

    end

    def start
      self.thread = Thread.new do

        cli.run

      end
    end

  end
end
