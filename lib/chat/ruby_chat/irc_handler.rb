

#require 'lib/ruby_chat/cluster'

module RubyChat

  class IrcHandler

    attr_accessor :clusters

    def initialize(args = nil)

      self.clusters = {}

      cluster = RubyChat::IRCluster.new(self)

      puts cluster.inspect

      add(cluster)

    end

    def handle(request)

      cluster = self.clusters[cluster_id]
      response = cluster.cli.send_request

    end

    def add(cluster)
      chash = { :virgo => cluster }
      self.clusters.merge!(chash)
    end


  end
end
