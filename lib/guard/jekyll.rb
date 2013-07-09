require 'guard'
require 'guard/guard'

require 'jekyll'

module Guard
  class Jekyll < Guard

    def initialize (watchers=[], options={})
      super

      default_extensions = ['md','markdown','textile','html','haml','slim','xml','yml']

      @options = {
        :extensions => [], 
        :config => ['_config.yml']
      }.merge(options)

      config = jekyll_config(@options)
      @site = ::Jekyll::Site.new config
      @source = local_path config['source']
      @destination = local_path config['destination']
      
      extensions = @options[:extensions].concat(default_extensions).flatten.uniq
      # Convert array of extensions into a regex for matching file extensions eg, /\.md$|\.markdown$|\.html$/i
      @extensions = Regexp.new extensions.map { |e| (e << '$').gsub('\.', '\\.') }.join('|'), true

    end

    # Calls #run_all if the :all_on_start option is present.
    def start
      UI.info 'Guard::Jekyll is watching for file changes'
      build
    end

    def reload
      build
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
      paths.each { |file| remove file }
    end


    private

    def build
      begin
        UI.info "Guard::Jekyll "+" building".yellow + " source: #{@source}, destination: #{@destination}"
        @site.process
        UI.info "Guard::Jekyll "+" complete".green + " #{@source} built to #{@destination}"

      rescue Exception => e
        UI.error "Guard::Jekyll build has failed"
        throw :task_has_failed
      end
    end
    
    # Copy static files to destination directory
    #
    def copy(file)
      begin
        path = destination_path file
        FileUtils.mkdir_p File.dirname(path)
        FileUtils.cp file, path
        UI.info "Guard::Jekyll" + "    copied ".green + "#{file} -> #{path}"
      rescue Exception => e
        UI.error "Guard::Jekyll copy has failed"
        UI.error e
        throw :task_has_failed
      end
    end

    # Remove deleted source file/directories from destination
    #
    def remove(file)
      path = destination_path file
      if File.exist? path
        begin

          FileUtils.rm path
          UI.info "Guard::Jekyll" + "   removed ".red + path

          dir = File.dirname path
          if Dir[dir+'/*'].empty?
            FileUtils.rm_r(dir) 
            UI.info "Guard::Jekyll" + "   removed ".red + dir
          end

        rescue Exception => e
          UI.error "Guard::Jekyll remove has failed"
          UI.error e
          throw :task_has_failed
        end

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
        build
      else
        copy_files.each   { |f| copy f }
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

  end
end

