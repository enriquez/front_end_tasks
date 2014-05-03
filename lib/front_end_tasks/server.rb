require 'webrick'

module FrontEndTasks
  class Server
    include WEBrick

    def self.start(opts)
      HTTPUtils::DefaultMimeTypes.store('manifest', 'text/cache-manifest')
      server = HTTPServer.new(:Port => opts[:port], :DocumentRoot => opts[:public_dir])
      trap("INT") { server.shutdown }
      server.start
    end

  end
end
