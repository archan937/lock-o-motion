require "colorize"
require "motion/gem_ext"

require "lock-o-motion/app"
require "lock-o-motion/version"

module LockOMotion
  extend self

  def setup(&block)
    Motion::Project::App.setup do |app|
      LockOMotion::App.setup app, &block
    end
  end

  def latest_load_paths
    @latest_load_paths ||= Dir["{#{::Gem.paths.path.join(",")}}" + "/gems/*/lib"]
  end

  def skip?(path)
    !!%w(openssl pry).detect{|x| path.match %r{\b#{x}\b}}.tap do |file|
      puts "   Warning Skipped '#{file}' requirement".yellow if file
    end
  end

end

unless defined?(Lotion)
  Lotion = LockOMotion
end