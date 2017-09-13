lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rredis/version"

Gem::Specification.new do |spec|
  spec.name          = "rredis"
  spec.version       = RRedis::VERSION
  spec.authors       = ["Lucas Dohmen"]
  spec.email         = ["lucas@dohmen.io"]

  spec.summary       = %q{A very simple implementation of Redis in Ruby}
  spec.description   = %q{Reimplements Redis in Ruby for educational purposes.}
  spec.homepage      = "https://github.com/moonglum/rredis"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
