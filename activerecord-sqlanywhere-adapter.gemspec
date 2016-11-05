# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/connection_adapters/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-sqlanywhere-adapter"
  spec.version       = Activerecord::ConnectionAdapters::VERSION
  spec.authors       = [%q{Eric Farar}]
  spec.email         = [%q{eric.farrar@ianywhere.com}]

  spec.summary       = %q{ActiveRecord driver for SQL Anywhere}
  spec.description   = %q{ActiveRecord driver for SQL Anywhere}
  spec.homepage      = %q{http://sqlanywhere.rubyforge.org}
  spec.license       = %q{Apache License Version 2.0}

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency(%q<sqlanywhere>, [">= 0.2.0"])
  spec.add_runtime_dependency(%q<activerecord>, [">= 5.0.0"])
  spec.required_ruby_version = '>= 2.2.2'
end

