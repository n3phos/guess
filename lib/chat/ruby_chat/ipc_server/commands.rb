
module RubyChat

  class IpcServer

    module Commands

      def irc_hello_test(id, payload)

        puts "received hello command"
        puts "target: #{id}"
        puts "payload: #{payload}"
        puts "hello"
      end

      def irc_create_bot(request)
        config = request.payload
        id = request.target

        bots.create(id, config)
      end

      def irc_ping(request)
        s = request.sock

        s.write("pong\n")
      end

      def irc_setup_bot_game(request)
        id = request.target
        b = bots[id]
        b.setup_game(request.payload)
      end

      def irc_start_bot(request)
        id = request.target
        bots[id].start
      end

      def irc_get_game_info(request)
        id = request.target
        s = request.sock

        b = bots[id]
        resp = b.game_info
        s.write(resp + "\n")
      end

    end

  end
end
