# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/beaker/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-beaker"
  spec.version       = Vagrant::Beaker::VERSION
  spec.authors       = ["Justin Stoller"]
  spec.email         = ["justin@puppetlabs.com"]
  spec.description   = %q{Provides a bridge so that Puppetlabs Test Tooling can be used within Vagrant}
  spec.summary       = %q{Use Beaker with Vagrant}
  spec.homepage      = "https://github.com/puppetlabs/vagrant-beaker/"
  spec.license       = "ASL 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency 'beaker'
end
