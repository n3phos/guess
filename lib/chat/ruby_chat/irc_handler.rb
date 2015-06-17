

#require 'lib/ruby_chat/cluster'

module RubyChat

  class IrcHandler

    attr_accessor :initialized, :cli, :bids

    def initialize(args = nil)

      self.bids = 0

      config = { 'port' => 31337 }

      # spawn IPC server, listens on port 31337
      spawned = spawn_controller_server

      if spawned
        # start IPC client, connects to IPC Server
        self.cli = RubyChat::IpcClient.new(config)
        self.initialized = cli.test
      end

    end

    def initialized?
      self.initialized
    end

    def setup_game(id, game_records)
      cli.request({ :action => "setup_game", :target => id, :payload => game_records})
    end

    def create_bot(config = default_config)
      bid = alloc_bid
      cli.request({ :action => "create_bot", :target => bid, :payload => config})

      return bid
    end

    def game_info(id)
      cli.request({ :action => "get_game_info", :target => id })
    end

    protected

    # new bot id
    def alloc_bid
      id = self.bids += 1
      bid = "virgo#bot_#{id}"
      bid
    end

    def spawn_controller_server
      spawned = false

      puts Dir.pwd

      pid = Process.spawn("ruby lib/chat/ruby_chat/ipc_server.rb")

      if pid
        spawned = true
        Process.detach(pid)
      end

      spawned
    end

    def default_config
      {
        'nick' => "nephos_bot",
        'channel' => "#nephos",
      }
    end


  end
end
