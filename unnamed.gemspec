# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unnamed/version'

Gem::Specification.new do |gem|
  gem.name          = "unnamed"
  gem.version       = Unnamed::VERSION
  gem.authors       = ["Michael Brodhead", "Blaine Carlson"]
  gem.email         = ["mkb@orthogonal.org", "blaineosiris@comcast.net"]
  gem.description   = %q{A client side HTTP load balancer.}
  gem.summary       = %q{Allocate load between multiple instances of an HTTP service. } +
      %q{Remove non-functioning servers from rotation and add them back when they become available.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('excon')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('travis-lint')
  gem.add_development_dependency('sinatra')
  gem.add_development_dependency('realweb')
end
