# encoding: utf-8

require 'benchmark'
require 'jekyll'
require 'guard/compat/plugin'

require 'guard/jekyll_plus/config'

module Guard
  class JekyllPlus < Plugin
    class Builder
      class Action
        def initialize(config, site)
          @config, @site = config, site
        end

        def jekyll_matches(paths)
          paths.select { |file| file =~ @config.extensions }
        end

        def non_jekyll_matches(paths)
          paths.select do |file|
            !file.match(/^_/) && !file.match(@config.extensions)
          end
        end

        def build(files, message, mark)
          @config.info [message, 'building...'.yellow].join(' ')

          if files
            puts '| ' # spacing
            files.each { |file| puts '|' + mark + file }
            puts '| ' # spacing
          end

          elapsed = Benchmark.realtime { @site.process }.round(2)

          change = format('%s → %s', @config.source, @config.destination)
          @config.info format('build completed in %ss '.green + change, elapsed)

          # rescue almost everything because Jekyll::Convertible forwards
          # every plugin-specific exception it encounters
        rescue StandardError => e
          @config.error 'build has failed'
          @config.error e.to_s
          throw :task_has_failed
        end

        def ignore_stitch_sources(files)
          return files unless (ignore = ENV['GUARD_STITCH_PLUS_FILES'])

          ignore = ignore.split(',')
          files.reject { |f| ignore.include? f }
        end

        def pluralize(word, array)
          "#{word}#{array.size > 1 ? 's' : ''}"
        end

        def destination_path(file)
          src_abs_path = Pathname(@config.source).expand_path

          abs_path = Pathname(file).expand_path
          rel_path = begin
                       abs_path.relative_path_from(src_abs_path)
                     rescue ArgumentError # probably happens only on Windows
                       raise "File not in Jekyll source dir: #{file}"
                     end

          (Pathname(@config.destination) + rel_path).to_s
        end

        def build_was_needed(paths)
          matched = jekyll_matches(paths)
          return false  if matched.empty?
          build(matched, @msg, @mark)
        end

        def update(paths)
          return if build_was_needed(paths)

          unmatched = non_jekyll_matches(paths)
          return if unmatched.empty?
          files = ignore_stitch_sources(unmatched)
          return if files.empty?

          do_update(files)
          footer
        rescue RuntimeError, SystemCallError => e
          @config.error "#{@name} has failed"
          @config.error e.to_s
          throw :task_has_failed
        end

        def copy(src, dst)
          if @config.excluded?(src)
            puts '|' + ('  ~ ' + "Ignoring excluded file: #{src}").yellow
            return
          end

          FileUtils.mkdir_p File.dirname(dst)
          FileUtils.cp src, dst
          puts '|' + '  → '.green + dst
        end

        def remove(path)
          if File.exist? path
            FileUtils.rm path
            puts '|' + '  → '.red + path
          end

          dir = File.dirname path
          return if Dir[dir + '/*'].any?

          FileUtils.rm_rk(dir)
          puts '|' + '  x '.red + dir
        end

        def header(files)
          plural = files.nil? ? '' : pluralize('file', files.size)
          @config.info [@activity, plural].join(' ').send(@color)
          puts '| ' unless files.nil? # spacing
        end

        def footer
          puts '| ' # spacing
        end
      end
    end
  end
end
