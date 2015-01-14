require 'jekyll'

require 'guard/compat/plugin'

require 'guard/jekyll_plus/config'

module Guard
  class JekyllPlus < Plugin
    class Server
      def initialize(config)
        @thread = nil
        @config = config
        @pid = nil
      end

      def start
        @rack = rack_available?
        @rack ? start_rack : start_jekyll

        msg = 'watching and serving using %s at %s:%s%s'
        type = @rack ? 'rack' : 'jekyll'
        msg = format(msg, type, @config.host, @config.port, @config.baseurl)
        @config.info msg
      end

      def stop
        @rack ? stop_rack : stop_jekyll
      end

      private

      def rack_available?
        @use_rack ||= begin
                         Kernel.require 'rack'
                         true
                       rescue LoadError
                         false
                       end
      end

      def local_config
        File.exist?('config.ru') ? 'config.ru' : nil
      end

      def default_config
        (Pathname(__FILE__).expand_path.dirname + '../../rack/config.ru').to_s
      end

      def config_file
        (@config.rack_config || local_config || default_config)
      end

      def start_jekyll
        # NOTE: must use process for Jekyll, because:
        #
        # 1) webrat has a shutdown that needs to be called. Since Jekyll
        # doesn't expose the server instance, the only way to call it is to
        # send "INT" to the process - but that also causes Pygments to crash
        # (because it's opening a pipe with Mentos)
        #
        # 2) you can't use the 'detach' option of Jekyll, because you don't
        # have access to the pid, because it's only logged and never returned
        #
        # You'll likely get a "Couldn't cleanly terminate all actors" error,
        # because Celluloid doesn't gracefully handle forking.
        #
        fail "Server already running at: #{@pid.inspect}" unless @pid.nil?
        @pid = Process.fork do
          ::Jekyll::Commands::Serve.process(@config.jekyll_serve_options)
        end
      end

      def start_rack
        fail 'already running!' unless @pid.nil?
        # Run rack in a process, because the only way to shut down Webrick
        # cleanly is through calling shutdown(), and Rack sets up and INT
        # handler specifically to do this - so we need to call INT.
        #
        # Webrick needs to shutdown
        # explicitly - and that's handled by Rack (it traps INT),
        ENV['RACK_ROOT'] = @config.server_root
        s = ::Rack::Server.new(config: config_file,
                               Port: @config.port,
                               Host: @config.host,
                               environment: @config.rack_environment)

        @config.info "Using: #{s.server} as server"

        thin = s.server == Rack::Handler::Thin
        Thin::Logging.silent = @config.rack_environment.nil? if thin

        @pid = Process.fork { s.start }
      end

      def stop_rack
        stop_pid
      end

      def stop_jekyll
        stop_pid
      end

      def stop_pid
        return if @pid.nil?
        Process.kill('INT', @pid)
        Process.wait(@pid)
        @pid = nil
      end
    end
  end
end
