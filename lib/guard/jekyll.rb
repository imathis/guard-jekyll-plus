# encoding: UTF-8

require 'guard'
require 'guard/guard'

require 'jekyll'

module Guard
  class Jekyll < Guard

    def initialize (watchers=[], options={})
      super

      default_extensions = ['md','mkd','markdown','textile','html','haml','slim','xml','yml']

      @options = {
        :extensions => [], 
        :config => ['_config.yml'],
        :serve => false
      }.merge(options)

      @pid = nil
      @config = jekyll_config(@options)
      @site = ::Jekyll::Site.new @config
      @source = local_path @config['source']
      @destination = local_path @config['destination']
      
      extensions = @options[:extensions].concat(default_extensions).flatten.uniq
      # Convert array of extensions into a regex for matching file extensions eg, /\.md$|\.markdown$|\.html$/i
      @extensions = Regexp.new extensions.map { |e| (e << '$').gsub('\.', '\\.') }.join('|'), true

    end

    def start

      if @options[:serve]
        start_server

        UI.info "Guard::Jekyll " + "watching and serving at #{@config['host']}:#{@config['port']}#{@config['baseurl']}"
      else
        build
        UI.info "Guard::Jekyll " + "watching"
      end
    end

    def restart
      stop if alive?
      start
    end


    def stop
      stop_server
    end

    def run_all
      build
    end

    def run_on_modifications(paths)
      changes(paths)
    end

    def run_on_additions(paths)
      changes(paths)
    end

    def run_on_removals(paths)
      remove paths
    end


    private

    def build(changes=nil)
      begin
        UI.info "Guard::Jekyll " + "building...".yellow
        if changes
          puts '| ' # spacing
          changes.each { |file| puts '|' + "  ~ ".yellow + file }
          puts '| ' # spacing
        end
        @site.process
        UI.info "Guard::Jekyll " + "build complete ".green + "#{@source} → #{@destination}"

      rescue Exception => e
        UI.error "Guard::Jekyll build has failed"
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
        UI.info "Guard::Jekyll #{message.green}"
        puts '| ' #spacing
        files.each do |file|
          path = destination_path file
          FileUtils.mkdir_p File.dirname(path)
          FileUtils.cp file, path
          puts '|' + "  → ".green + path
        end
        puts '| ' #spacing

      rescue Exception => e
        UI.error "Guard::Jekyll copy has failed"
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
        UI.info "Guard::Jekyll #{message.red}"
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
        UI.error "Guard::Jekyll remove has failed"
        UI.error e
        stop_server
        throw :task_has_failed
      end
      true
    end

    def changes(paths)
      matches = []
      copy_files = []

      paths.each do |file|
        if file =~ @extensions
          matches.push file 
        else
          copy_files.push file
        end
      end

      # If changes match Jekyll extensions, trigger a build else, copy files manually
      # 
      if matches.length > 0
        build(matches)
      else
        copy(copy_files)
      end
    end

    def jekyll_config(options)
      config_files = options[:config]
      config_files = [config_files] unless config_files.is_a? Array
      ::Jekyll.configuration({ "config" => config_files })
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

    def server
      proc{ Process.spawn "jekyll server --config #{@options[:config].join(',')}" }
    end

    def kill
      proc{|pid| Process.kill("QUIT", pid)}
    end

    def start_server
      return @pid if alive?
      @pid = instance_eval &server
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

