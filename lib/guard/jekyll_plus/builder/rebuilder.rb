# encoding: utf-8

require 'guard/jekyll_plus/builder/action'

module Guard
  class JekyllPlus < Plugin
    class Builder
      class Rebuilder < Action
        def initialize(*args)
          @name = 'build'
          @activity = 'building...'
          @color = :yellow
          super
        end

        def update
          header(nil)
          benchmark { @site.process }

        # rescue almost everything because Jekyll::Convertible forwards
        # every plugin-specific exception it encounters
        rescue StandardError => e
          @config.error "#{@name} has failed"
          @config.error e.to_s
          throw :task_has_failed
        end

        def benchmark
          elapsed = Benchmark.realtime { yield }.round(2)
          change = format('%s → %s', @config.source, @config.destination)
          msg = format('build completed in %ss '.green + change, elapsed)
          @config.info msg
        end
      end
    end
  end
end
