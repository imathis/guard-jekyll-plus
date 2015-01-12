# encoding: UTF-8

require 'pathname'

require 'jekyll'

require 'guard/compat/plugin'

require 'guard/jekyll-plus/server'
require 'guard/jekyll-plus/config'
require 'guard/jekyll-plus/builder'

module Guard
  class Jekyllplus < Plugin
    def initialize(options = {})
      super

      @config = Config.new(options)
      @server = Server.new(@config)
      @builder = Builder.new(@config)
    end

    def start
      @builder.build
      @server.start if @config.serve?
      @config.info 'watching'
    end

    def reload
      stop
      @config.info 'Reloading Jekyll configuration!'
      @config.reload
      @builder.reload
      start
    end

    def stop
      @server.stop
    end

    def run_on_modifications(paths)
      reload if paths.any? { |f| @config.config_file?(f) }
      @builder.modified(paths)
    end

    def run_on_additions(paths)
      @builder.added(paths)
    end

    def run_on_removals(paths)
      @builder.removed(paths)
    end
  end
end
