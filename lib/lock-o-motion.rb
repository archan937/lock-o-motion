require "colorize"
require "motion/gem_ext"

require "lock-o-motion/app"
require "lock-o-motion/version"

module LockOMotion
  extend self

  USER_MOCKS = File.expand_path("./mocks")
  GEM_MOCKS  = File.expand_path("../lock-o-motion/mocks", __FILE__)

  class GemPath
    attr_reader :name, :version, :path, :version_numbers
    include Comparable

    def initialize(path)
      @name, @version = File.basename(path).scan(/^(.+?)-([^-]+)$/).flatten
      @path = path
      @version_numbers = @version.split(/[^0-9]+/).collect(&:to_i)
    end

    def <=>(other)
      raise "Not comparable gem paths ('#{name}' is not '#{other.name}')" unless name == other.name
      @version_numbers <=> other.version_numbers
    end
  end

  def setup(&block)
    Motion::Project::App.setup do |app|
      LockOMotion::App.setup app, &block
    end
  end

  def mocks_dirs
    @mocks_dirs ||= [USER_MOCKS, GEM_MOCKS]
  end

  def gem_paths
    @gem_paths ||= Dir["{#{::Gem.paths.path.join(",")}}" + "/gems/*"].inject({}) do |gem_paths, path|
      gem_path = GemPath.new path
      gem_paths[gem_path.name] ||= gem_path
      gem_paths[gem_path.name] = gem_path if gem_paths[gem_path.name] < gem_path
      gem_paths
    end.values.collect do |gem_path|
      gem_path.path + "/lib"
    end.sort
  end

  def add_mocks_dir(dir)
    mocks_dirs.insert 1, dir
  end

  def skip?(path)
    !!%w(openssl pry).detect{|x| path.match %r{\b#{x}\b}}.tap do |file|
      puts "   Warning Skipped '#{file}' requirement".yellow if file
    end
  end

  def mock_path(path)
    path = path.gsub(/\.rb$/, "")

    mocks_dirs.each do |dir|
      if File.exists?(file = File.expand_path("#{dir}/#{path}.rb"))
        return file
      end
    end

    nil
  end

end

unless defined?(Lotion)
  Lotion = LockOMotion
end