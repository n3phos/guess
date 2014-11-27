
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

      def irc_feed_bot(request)
        id = request.target
        wordlist = request.payload

        bots[id].feed(wordlist)
      end

      def irc_start_bot(request)
        id = request.target
        bots[id].start
      end

    end

  end
end
