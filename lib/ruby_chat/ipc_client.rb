


module RubyChat

  class IpcClient

    attr_accessor :port, :bots, :sock, :cluster

    def initialize(cluster, config)
      self.cluster = cluster
      self.port = config['port']
      self.bots = {}

      sleep 2

      puts "connecting..."

      self.sock = TCPSocket.new("127.0.0.1", 31337)

    end

    def setup_bot_game(id, game_records)
      req = create_request({ :action => "setup_bot_game", :target => id, :payload => game_records})
      send_request(req)
    end

    def create_bot(config = default_config)
      id = self.cluster.alloc_bid

      req = create_request({ :action => "create_bot", :target => id, :payload => config})
      send_request(req)
    end

    def start_bot(id)
      req = create_request({ :action => "start_bot", :target => id })
      send_request(req)
    end

    

    def stop_bot(id)
    end

    def test
      rs = []
      rs << self.sock
      response = nil

      puts "sending ping..."

      req = create_request({ :action => "ping" })
      send_request(req)

      readfs = select(rs, nil, nil, 0.1)
      if readfs
        response = sock.gets
        puts "received response"
      else
        return false
      end


      if response.match(/pong/)
        return true
      else
        return false
      end
    end

    def create_request(req)
      req.inspect
    end

    def send_request(request)
      request << "\n"
      sock.write(request)
    end

    def default_config
    {
      'nick' => "nephos_bot",
      'channel' => "#nephos",
    }
    end

  end


end




