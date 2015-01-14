# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/jekyll_plus/version'

Gem::Specification.new do |gem|
  gem.name          = 'guard-jekyll-plus'
  gem.version       = Guard::JekyllPlusVersion::VERSION
  gem.authors       = ['Brandon Mathis']
  gem.email         = ['brandon@imathis.com']
  gem.description   = 'A Guard plugin for smarter Jekyll watching'
  gem.summary       = 'A Guard plugin for Jekyll which intelligently handles'\
                      ' changes to static and template files, only running a'\
                      ' Jekyll build when necessary. '

  gem.homepage      = 'http://github.com/imathis/guard-jekyll-plus'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.require_paths = ['lib']

  gem.add_dependency 'guard', '~> 2.10', '>= 2.10.3'
  gem.add_dependency 'guard-compat', '~> 1.1'
  gem.add_dependency 'jekyll', '>= 1.0.0'

  # Note: we use these for test depedencies, because it's more convenient
  # to use Gemfile for development deps
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.1'
  gem.add_development_dependency 'nenv', '~> 0.1'

  gem.add_development_dependency 'bundler' if RUBY_VERSION >= '2'
end
