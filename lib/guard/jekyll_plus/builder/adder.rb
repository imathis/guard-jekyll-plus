require 'guard/jekyll_plus/builder/action'

module Guard
  class JekyllPlus < Plugin
    class Builder
      class Adder < Action
        def initialize(*args)
          @msg = 'Files added: '
          @mark = '  + '.green
          @name = 'copy'
          @activity = 'copying'
          @color = :green
          super
        end

        def do_update(files)
          header(files)
          files.each { |file| copy(file, destination_path(file)) }
        end
      end
    end
  end
end
