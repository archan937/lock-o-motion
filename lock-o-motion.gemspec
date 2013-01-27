# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Engel"]
  gem.email         = ["paul.engel@holder.nl"]
  gem.summary       = %q{Require RubyGems (including their dependencies) within RubyMotion Apps}
  gem.description   = %q{Require RubyGems (including their dependencies) within RubyMotion Apps}
  gem.homepage      = "https://github.com/archan937/lock-o-motion"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "lock-o-motion"
  gem.require_paths = ["lib"]
  gem.version       = "0.1.0"

  gem.add_dependency "pry"
  gem.add_dependency "rich_support", "~> 0.1.2"
  gem.add_dependency "thor"        , "~> 0.14.6"
end