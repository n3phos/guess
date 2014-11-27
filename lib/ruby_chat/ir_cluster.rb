

module RubyChat

  class IRCluster

    attr_accessor :cli, :handler, :id_pool, :name, :initialized

    def initialize(handler, opts = {})

      self.handler = handler
      self.id_pool = 0
      self.name = opts['name'] || "virgo"
      self.initialized = false

      config = { 'port' => 31337 }

      spawned = spawn_controller_server

      if spawned
        self.cli = RubyChat::IpcClient.new(self, config)
        self.initialized = cli.test
      end



    end

    def alloc_bid
      id = self.id_pool += 1
      bid = "#{self.name}#bot_#{id}"
      bid
    end

    def initialized?
      self.initialized
    end

    def spawn_controller_server
      spawned = false

      puts Dir.pwd

      pid = Process.spawn("ruby lib/ruby_chat/ipc_server.rb")

      if pid
        spawned = true
        Process.detach(pid)
      end

      spawned
    end


  end
end
