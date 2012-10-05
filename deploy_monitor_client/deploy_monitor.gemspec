# -*- encoding: utf-8 -*-
require File.expand_path('../lib/deploy_monitor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Greenberg"]
  gem.email         = ["greenberg@twitter.com"]
  gem.description   = "Command-line client and Ruby client for Deploy Monitor"
  gem.summary       = "Client to connect to Deploy Monitor"
  gem.homepage      = 'http://github.com/ryangreenberg/deploy_monitor'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "deploy_monitor"
  gem.require_paths = ['lib']
  gem.version       = DeployMonitor::VERSION

  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'rest-client'
  gem.add_runtime_dependency 'highline'
end
