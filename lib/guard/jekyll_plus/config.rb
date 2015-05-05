require 'jekyll'

module Guard
  class JekyllPlus < Plugin
    class Config
      EXTS = %w(md mkd mkdn markdown textile html haml slim xml yml sass scss)

      def initialize(options)
        @options = {
          extensions: [],
          config: ['_config.yml'],
          serve: false,
          rack_config: nil,
          drafts: false,
          future: false,
          config_hash: nil,
          silent: false,
          msg_prefix: 'Jekyll '
        }.merge(options)

        @jekyll_config = load_config(@options)

        @source = local_path(@jekyll_config['source'])
        @destination = local_path(@jekyll_config['destination'])
        @msg_prefix = @options[:msg_prefix]

        # Convert array of extensions into a regex for matching file extensions
        # eg, /\.md$|\.markdown$|\.html$/i
        #
        extensions  = @options[:extensions].concat(EXTS).flatten.uniq
        extensions.map! { |e| Regexp.quote(e.sub(/^\./, '')) }
        @extensions = /\.(?:#{extensions.join('|')})$/i
      end

      attr_reader :extensions
      attr_reader :destination
      attr_reader :jekyll_config

      def server_options
        jekyll_config
      end

      def config_file?(file)
        @options[:config].include?(file)
      end

      def reload
        @jekyll_config = load_config(@options)
      end

      def info(msg)
        Compat::UI.info(@msg_prefix + msg) unless silent?
      end

      def error(msg)
        Compat::UI.error(@msg_prefix + msg)
      end

      def source
        @jekyll_config['source']
      end

      def serve?
        @options[:serve]
      end

      def host
        @jekyll_config['host']
      end

      def baseurl
        @jekyll_config['baseurl']
      end

      def port
        @jekyll_config['port']
      end

      def rack_config
        @options[:rack_config]
      end

      def rack_environment
        silent? ? nil : 'development'
      end

      alias_method :server_root, :destination
      alias_method :jekyll_serve_options, :jekyll_config

      def excluded?(path)
        @jekyll_config['exclude'].any? { |glob| File.fnmatch?(glob, path) }
      end

      def watch_regexp
        %r{^(?!#{destination}\/).*}
      end

      private

      def silent?
        @options[:silent] || @options['silent']
      end

      def load_config(options)
        config = ::Jekyll.configuration(jekyllize_options(options))

        # Override configuration with guard option values
        config['show_drafts'] = options[:drafts]
        config['future']      = options[:future]
        config
      end

      def jekyllize_options(options)
        opts = options.dup
        return opts[:config_hash] if opts[:config_hash]
        return opts unless opts[:config]
        opts[:config] = [opts[:config]] unless opts[:config].is_a? Array
        opts
      end

      def local_path(path)
        # TODO: what is this for?
        Dir.chdir('.')

        current = Dir.pwd
        path = path.sub current, ''
        if path == ''
          './'
        else
          path.sub(%r{^/}, '')
        end
      end
    end
  end
end
