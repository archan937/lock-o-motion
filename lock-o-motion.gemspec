# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Engel"]
  gem.email         = ["paul.engel@holder.nl"]
  gem.summary       = %q{Require and mock Ruby gems (including their dependencies) within RubyMotion applications}
  gem.description   = %q{Require and mock Ruby gems (including their dependencies) within RubyMotion applications}
  gem.homepage      = "https://github.com/archan937/lock-o-motion"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "lock-o-motion"
  gem.require_paths = ["lib"]
  gem.version       = "0.1.0"

  gem.add_dependency "colorize"
end