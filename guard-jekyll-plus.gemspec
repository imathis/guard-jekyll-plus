# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/jekyll-plus/version'

Gem::Specification.new do |gem|
  gem.name          = "guard-jekyll-plus"
  gem.version       = Guard::JekyllPlusVersion::VERSION
  gem.authors       = ["Brandon Mathis"]
  gem.email         = ["brandon@imathis.com"]
  gem.description   = %q{A Guard plugin for smarter Jekyll watching}
  gem.summary       = %q{A Guard plugin for Jekyll which intelligently handles changes to static and template files, only running a Jekyll build when necessary. }
  gem.homepage      = "http://github.com/imathis/guard-jekyll-plus"
  gem.license       = 'MIT'

  gem.add_dependency 'guard', '>= 1.1.0'
  gem.add_dependency 'jekyll', '>= 1.0.0'
  
  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
end
