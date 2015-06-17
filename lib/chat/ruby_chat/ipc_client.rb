


module RubyChat

  class IpcClient

    attr_accessor :port, :sock

    def initialize(config)
      self.port = config['port']

      sleep 1

      puts "connecting..."

      self.sock = TCPSocket.new("127.0.0.1", self.port)
    end

    def request(req)
      r = create_request(req)
      send_request(r)
    end

    def test
      req = create_request({ :action => "ping" })
      resp = send_request(req)

      if resp.match(/pong/)
        return true
      else
        return false
      end
    end

    def create_request(req)
      req.inspect
    end

    def send_request(request)
      rs = [self.sock]
      response = nil

      request << "\n"
      sock.write(request)

      readfs = select(rs, nil, nil, 0.1)
      if readfs
        response = sock.gets
      else
        return false
      end

      response
    end

  end
end




