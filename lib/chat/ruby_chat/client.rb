
require 'emirc'

module RubyChat

  class Client < IRC::Client

    def initialize(options = {}, &blk)

      super

      #Client.init_reply_callbacks
    end

  end

end
