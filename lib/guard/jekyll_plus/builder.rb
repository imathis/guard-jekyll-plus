require 'jekyll'

require 'guard/jekyll_plus/config'

require 'guard/jekyll_plus/builder/modifier'
require 'guard/jekyll_plus/builder/adder'
require 'guard/jekyll_plus/builder/remover'
require 'guard/jekyll_plus/builder/rebuilder'

module Guard
  class JekyllPlus < Plugin
    class Builder
      def initialize(config)
        @config = config
        reload
      end

      def reload
        Jekyll.logger.log_level = :error
        @site = ::Jekyll::Site.new(@config.jekyll_config)
        Jekyll.logger.log_level = :info

        @adder = Adder.new(@config, @site)
        @modifier = Modifier.new(@config, @site)
        @remover = Remover.new(@config, @site)
        @rebuilder = Rebuilder.new(@config, @site)
      end

      def build
        @rebuilder.update
      end

      def added(paths)
        @adder.update(paths)
      end

      def modified(paths)
        @modifier.update(paths)
      end

      def removed(paths)
        @remover.update(paths)
      end
    end
  end
end
