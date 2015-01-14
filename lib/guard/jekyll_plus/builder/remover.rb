require 'guard/jekyll_plus/builder/action'

module Guard
  class JekyllPlus < Plugin
    class Builder
      class Remover < Action
        def initialize(*args)
          @msg = 'Files removed: '
          @mark = '  x '.red
          @name = 'remove'
          @activity = 'removing'
          @color = :red
          super
        end

        def do_update(files)
          return if files.none? { |f| File.exist?(f) }
          header(files)
          files.each { |file| remove(destination_path(file)) }
        end
      end
    end
  end
end
