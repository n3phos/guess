
$:.unshift File.expand_path '..', __FILE__

require 'socket'
require 'ipc_server/commands'
require 'botmanager'
require 'ostruct'

module RubyChat

  class IpcServer

    include Commands

    def initialize(config = {})

      self.config = {}
      self.config.merge!(
        {
          'host' => "127.0.0.1",
          'port' => 31337
        })

      self.bots = BotManager.new(self)

    end

    def start

      serv = TCPServer.new(host, port)

      rails_client = serv.accept

      puts "rails client connected: #{rails_client.inspect}"

      serve(rails_client)

    end

    def serve(client)

      rs = []

      rs << client

      loop do

        read = nil
        read = IO.select(rs, nil, nil, nil)
        if read
          data = client.readline
          packet = parse(data, client)
          handle_request(packet)
        end
      end

    end

    def handle_request(packet)
      cmd_queue = []

      action = "irc_#{packet.action}"

      if self.respond_to?(action)

        begin

          cmd_queue << Thread.new do
            self.send(action, packet)
          end

        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end

      end
    end

    def parse(data, socket)
      os = nil

      # create hash
      h = eval(data)

      h[:sock] = socket

      puts h

      os = OpenStruct.new(h)

      puts os

      os
    end

    def host
      config['host']
    end

    def port
      config['port']
    end


    attr_accessor :config
    attr_accessor :bots


  end
end

handler = RubyChat::IpcServer.new

puts "Starting irc handler..."

handler.start
