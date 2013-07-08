# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/jekyll/version'

Gem::Specification.new do |gem|
  gem.name          = "guard-jekyll-plus"
  gem.version       = Guard::Jekyll::VERSION
  gem.authors       = ["Brandon Mathis"]
  gem.email         = ["brandon@imathis.com"]
  gem.description   = %q{guard for smarter Jekyll watching}
  gem.summary       = %q{guard for smarter Jekyll watching}
  gem.homepage      = "http://github.com/imathis/guard-jekyll-plus"

  gem.add_dependency 'guard', '>= 1.1.0'
  gem.add_dependency 'jekyll', '>= 1.0.0'
  
  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
end
