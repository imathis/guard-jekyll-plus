require 'guard'
require 'guard/guard'

require 'jekyll'

module Guard
  class Jekyll < Guard

    def initialize (watchers=[], options={})
      super

      default_extensions = ['md','markdown','textile','html','haml','slim','xml']

      @options = {
        :extensions => [], 
        :config => ['_config.yml']
      }.merge(options)

      config = @options[:config]
      config = [config] unless config.is_a? Array
      config = ::Jekyll.configuration {'config'=> config}

      @site = ::Jekyll::Site.new config
      @source = config['source']
      @destination = config['destination']
      
      extensions = @options[:extensions].concat(default_extensions).flatten.uniq
      # Convert array of extensions into a regex for matching file extensions eg, /\.md$|\.markdown$|\.html$/i
      @extensions = Regexp.new extensions.map { |e| (e << '$').gsub('\.', '\\.') }.join('|'), true

    end

    # Calls #run_all if the :all_on_start option is present.
    def start
      UI.info 'Guard::Jekyll is watching for file changes'
      rebuild
    end

    def reload
      compile
    end

    def run_all
      rebuild
    end

    def run_on_changes(paths)
      matches = []
      copy_files = []
      remove_files = []
      paths.each do |file|
        if File.exist? file
          if file =~ @extensions or file !=~ /^#{@source}/
            matches.push file 
          else
            copy_files.push file
          end
        else
          remove_files.push file
        end
      end

      if matches.length > 0
        rebuild
      else
        # If changes don't trigger Jekyll extension matches
        # manually copy and remove changed files
        copy_files.each   { |f| copy f }
        remove_files.each { |f| remove f }
      end
    end

    private

    def destination_path(file)
      file.sub /^#{@source}/, "#{@destination}"
    end

    def copy(file)
      destination_file = destination_path file
      FileUtils.mkdir_p File.dirname(destination_file)
      FileUtils.cp file, destination_file
      UI.info "Guard::Jekyll" + "    copied ".yellow + "#{file} -> #{destination_file}"
      true
    end

    def remove(file)
      destination_file = destination_path file
      if File.exist? destination_file
        begin
          # Remove deleted source file from destination
          FileUtils.rm destination_file
          UI.info "Guard::Jekyll" + "   delete ".red + destination_file

          # Remove empty directories from destination
          dir = File.dirname destination_file
          if Dir[dir+'/*'].empty?
            FileUtils.rm_r(dir) 
            UI.info "Guard::Jekyll" + "   delete ".red + dir
          end
        rescue Exception => e
          UI.error "Guard::Jekyll" + "   failed ".red + e
          throw :task_has_failed
        end

      end
      true
    end

    def rebuild
      UI.info "Guard::Jekyll "+" building".yellow + " source: #{@source}, destination: #{@destination}"
      @site.process
      UI.info "Guard::Jekyll "+" complete".green + " #{@source} built to #{@destination}"

    rescue Exception => e
      UI.error "Guard::Jekyll   failed"
      throw :task_has_failed
    end
    
  end
end

