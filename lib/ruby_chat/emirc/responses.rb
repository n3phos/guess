  module IRC
    # This module defines callbacks for IRC server responses
    module Responses
  #    extend ActiveSupport::Concern

      #  class_attribute :server_callbacks

        def self.included(base)
          base.extend(ClassMethods)
        end


      module ClassMethods
        attr_accessor :server_callbacks

        def init_reply_callbacks

            self.server_reply 'PRIVMSG' do |m|
              who     = sender_nick(m[:prefix])
              channel = m[:params].first
              message = m[:params].slice(1..-1).join(' ').gsub(/^:/, '')
              trigger(:message, who, channel, message)
            end

            self.server_reply '001', 'RPL_WELCOME' do |m|
              @nick = m[:params].first
              trigger(:nick, @nick)
            end

            self.server_reply 'PING' do |m|
              pong(m[:params].first)
              trigger(:ping, *m[:params])
            end

            self.server_reply 'JOIN' do |m|
              trigger(:join, sender_nick(m[:prefix]), m[:params].first)
            end

            self.server_reply '433', 'ERR_NICKNAMEINUSE' do |m|
              @nick = nil
            end
        end


        def server_reply(*cmds, &blk)
          cmds << cmds.first if cmds.size == 1
          self.server_callbacks ||= {}
          self.server_callbacks[cmds.first] = {
            :name     => cmds.last,
            :callback => block_given? ? blk : lambda {|m|
              trigger(cmd.last.downcase.to_sym, *m[:params])
            }
          }
        end
      end

      # @return [Hash] h
      # @option h [String] :prefix
      # @option h [String] :command
      # @option h [Array] :params
      # @private
      def parse_message(message)
        # TODO: error handling
        result = {}

        parts = message.split(' ')
        result[:prefix]  = parts.shift.gsub(/^:/, '') if parts[0] =~ /^:/
        result[:command] = parts.shift
        result[:params]  = parts.take_while {|e| e[0] != ':'}
        if result[:params].size < parts.size
          full_string = parts.slice(result[:params].size..-1).join(" ")
          full_string.gsub!(/^:/, '')
          result[:params] << full_string
        end
        result
      end

      # @private
      def handle_parsed_message(m)

        if handler = self.class.server_callbacks[m[:command]]
          instance_exec(m, &handler[:callback])
          # error codes 400 to 599
          trigger(:error, handler[:name]) if (m[:command].to_i / 100) > 3
        else
          log Logger::ERROR, "Unimplemented command: #{m[:prefix]} #{m[:command]} #{m[:params].join(' ')}"
        end
      end

      protected
      # @private
      def sender_nick(prefix)
        prefix.split('!').first
      end
    end
  end
