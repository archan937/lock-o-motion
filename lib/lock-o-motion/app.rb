require "lock-o-motion/app/hooks"
require "lock-o-motion/app/writer"

module LockOMotion
  class App

    include Hooks
    include Writer

    def self.setup(app, &block)
      new(app).send :setup, &block
    end

    def initialize(app)
      @app = app
    end

    def require(path, internal = false)
      Kernel.require path, internal
    end

    def ignore_require(path)
      @ignored_requires << path
    end

  private

    def setup(&block)
      @files = []
      @ignored_requires = []

      hook do
        Bundler.require :lotion
        require "colorize", true
        LockOMotion.default_files.select{|x| x[1]}.each do |default_file|
          require default_file.first
        end
        yield self if block_given?
        require File.expand_path(USER_LOTION) if File.exists?(USER_LOTION)
      end

      bundler = @dependencies.delete("BUNDLER") || []
      gem_lotion = @dependencies.delete("GEM_LOTION") || []
      user_lotion = @dependencies.delete("USER_LOTION") || []
      default_files = LockOMotion.default_files.reject{|x| x[1]}.collect(&:first)

      LockOMotion.default_files.each do |file, internal, dependencies|
        (dependencies || []).each do |dependency|
          (@dependencies[file] ||= []) << dependency
        end
      end
      gem_lotion.each do |file|
        default_files.each do |default_file|
          (@dependencies[default_file] ||= []) << file
        end
      end
      (bundler + user_lotion).each do |file|
        @dependencies[file] ||= []
        @dependencies[file] = default_files + @dependencies[file]
      end

      @files = (LockOMotion.default_files.collect(&:first) + gem_lotion.sort + bundler.sort + (@dependencies.keys + @dependencies.values).flatten.sort + user_lotion.sort + @app.files).uniq
      @app.files = @files
      @app.files_dependencies @dependencies
      write_lotion
    end

  end
end