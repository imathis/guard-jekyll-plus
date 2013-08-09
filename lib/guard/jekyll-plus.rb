# encoding: UTF-8

require 'guard'
require 'guard/guard'

require 'jekyll'
#begin require 'thin' rescue false end
begin
  require 'rack'
  USE_RACK = true
rescue LoadError
end

module Guard
  class Jekyllplus < Guard

    def initialize (watchers=[], options={})
      super

      default_extensions = ['md','mkd','mkdn','markdown','textile','html','haml','slim','xml','yml']

      @options = {
        :extensions     => [], 
        :config         => ['_config.yml'],
        :serve          => false,
        :rack_config    => nil,
        :drafts         => false,
        :future         => false,
        :config_hash    => nil,
        :silent         => false,
        :msg_prefix     => 'Jekyll'
      }.merge(options)

      # The config_hash option should be a hash ready to be consumed by Jekyll's Site class.
      #
      @config = jekyll_config(@options)

      # Override configuration with guard option values
      #
      @config['show_drafts'] ||= @options[:drafts]
      @config['future']      ||= @options[:future]

      # Store vars for easy internal access
      #
      @source = local_path @config['source']
      @destination = local_path @config['destination']
      @msg_prefix = @options[:msg_prefix]
 
      # Convert array of extensions into a regex for matching file extensions eg, /\.md$|\.markdown$|\.html$/i
      #
      extensions  = @options[:extensions].concat(default_extensions).flatten.uniq
      @extensions = Regexp.new extensions.map { |e| (e << '$').gsub('\.', '\\.') }.join('|'), true

      # set Jekyll server process id to nil
      #
      @pid = nil

      # Create a Jekyll site
      #
      @site = ::Jekyll::Site.new @config
      @rack = ::Rack::Server.new(rack_config(@destination)) if USE_RACK

    end

    def start
      if @options[:serve]
        start_server
        build
        UI.info "#{@msg_prefix} " + "watching and serving at #{@config['host']}:#{@config['port']}#{@config['baseurl']}" unless @config[:silent]
      else
        build
        UI.info "#{@msg_prefix} " + "watching" unless @config[:silent]
      end
    end

    def restart
      stop if alive?
      start
    end


    def stop
      stop_server
    end

    def run_on_modifications(paths)
      matched = jekyll_matches paths
      unmatched = non_jekyll_matches paths

      if matched.size > 0
        build(matched, "Files changed: ", "  ~ ".yellow)
      elsif unmatched.size > 0
        copy(unmatched)
      end
    end

    def run_on_additions(paths)
      matched = jekyll_matches paths
      unmatched = non_jekyll_matches paths

      if matched.size > 0
        build(matched, "Files added: ", "  + ".green)
      elsif unmatched.size > 0
        copy(unmatched)
      end
    end

    def run_on_removals(paths)
      matched = jekyll_matches paths
      unmatched = non_jekyll_matches paths

      if matched.size > 0
        build(matched, "Files removed: ", "  x ".red)
      elsif unmatched.size > 0
        remove(unmatched)
      end
    end


    private

    def build(files = nil, message = '', mark = nil)
      begin
        UI.info "#{@msg_prefix} #{message}" + "building...".yellow unless @config[:silent]
        if files
          puts '| ' # spacing
          files.each { |file| puts '|' + mark + file }
          puts '| ' # spacing
        end
        @site.process
        UI.info "#{@msg_prefix} " + "build complete ".green + "#{@source} → #{@destination}" unless @config[:silent]

      rescue Exception => e
        UI.error "#{@msg_prefix} build has failed" unless @config[:silent]
        stop_server
        throw :task_has_failed
      end
    end

    # Copy static files to destination directory
    #
    def copy(files=[])
      begin
        message = 'copied file'
        message += 's' if files.size > 1
        UI.info "#{@msg_prefix} #{message.green}" unless @config[:silent]
        puts '| ' #spacing
        files.each do |file|
          path = destination_path file
          FileUtils.mkdir_p File.dirname(path)
          FileUtils.cp file, path
          puts '|' + "  → ".green + path
        end
        puts '| ' #spacing

      rescue Exception => e
        UI.error "#{@msg_prefix} copy has failed" unless @config[:silent]
        UI.error e
        stop_server
        throw :task_has_failed
      end
      true
    end

    # Remove deleted source file/directories from destination
    #
    def remove(files=[])
      begin
        message = 'removed file'
        message += 's' if files.size > 1
        UI.info "#{@msg_prefix} #{message.red}" unless @config[:silent]
        puts '| ' #spacing

        files.each do |file|
          path = destination_path file
          if File.exist? path
            FileUtils.rm path
            puts '|' + "  x ".red + path
          end

          dir = File.dirname path
          if Dir[dir+'/*'].empty?
            FileUtils.rm_r(dir) 
            puts '|' + "  x ".red + dir
          end
        end
        puts '| ' #spacing

      rescue Exception => e
        UI.error "#{@msg_prefix} remove has failed" unless @config[:silent]
        UI.error e
        stop_server
        throw :task_has_failed
      end
      true
    end

    def jekyll_matches(paths)
      paths.select { |file| file =~ @extensions }
    end

    def non_jekyll_matches(paths)
      paths.select { |file| !file.match(/^_/) and !file.match(@extensions) }
    end

    def jekyll_config(options)
      if options[:config_hash]
        config = options[:config_hash]
      elsif options[:config]
        options[:config] = [options[:config]] unless options[:config].is_a? Array
        config = options
      end
      ::Jekyll.configuration(config)
    end

    def rack_config(root)
      ENV['RACK_ROOT'] = root
      default_config = File.expand_path("../rack/config.ru", File.dirname(__FILE__))
      local_config = File.exist?('config.ru') ? 'config.ru' : nil

      config = (@config['rack_config'] || local_config || default_config)
      { :config => config, :Port => @config['port'], :Host => @config['host'] }
    end

    def local_path(path)
      Dir.chdir('.')
      current = Dir.pwd
      path = path.sub current, ''
      if path == ''
        './'
      else 
        path.sub /^\//, ''
      end
    end
    
    def destination_path(file)
      if @source =~ /^\./
        File.join @destination, file
      else
        file.sub /^#{@source}/, "#{@destination}"
      end
    end

    # Remove 
    def ignore_underscores(paths)
      paths.select { |file| file =~ /^[^_]/  }
    end

    def server(config)
      if @rack
        proc{ Process.fork { @rack.start } }
      else
        proc{ Process.fork { ::Jekyll::Commands::Serve.process(config) } }
      end
    end

    def kill
      proc{|pid| Process.kill("INT", pid)}
    end

    def start_server
      return @pid if alive?
      @pid = instance_eval &server(@config)
    end

    def stop_server
      if alive?
        instance_eval do
          kill.call(@pid)
          @pid = nil
        end
      end
    end
    
    def alive?
      return false unless @pid

      begin
        Process.getpgid(@pid)
        true
      rescue Errno::ESRCH => e
        false
      end
    end
  end
end

