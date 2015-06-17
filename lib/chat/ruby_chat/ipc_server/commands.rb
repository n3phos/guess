
module RubyChat
class IpcServer

    module Commands

      def cmd_hello_test(id, payload)
        puts "received hello command"
        puts "target: #{id}"
        puts "payload: #{payload}"
        puts "hello"
      end

      def cmd_create_bot(request)
        config = request.payload
        id = request.target

        bots.create(id, config)
      end

      def cmd_ping(request)
        s = request.sock

        s.write("pong\n")
      end

      def cmd_setup_game(request)
        id = request.target
        b = bots[id]
        b.setup_game(request.payload)
      end

      def cmd_start_bot(request)
        id = request.target
        bots[id].start
      end

      def cmd_get_game_info(request)
        id = request.target
        s = request.sock

        b = bots[id]
        info = b.game_info
        s.write(info + "\n")
      end

    end

  end
end
