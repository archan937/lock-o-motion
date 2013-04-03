require "lock-o-motion/app/writer"

module LockOMotion
  class App
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

    def dependency(call, path, internal = false)
      call = "BUNDLER" if call.match(/\bbundler\b/)
      if call == __FILE__
        call = internal ? "GEM_LOTION" : "USER_LOTION"
      end

      ($: + LockOMotion.gem_paths).each do |load_path|
        if File.exists?(absolute_path = "#{load_path}/#{path}.bundle") ||
           File.exists?(absolute_path = "#{load_path}/#{path}.rb")
          if absolute_path.match(/\.rb$/)
            register_dependency call, absolute_path
            $:.unshift load_path unless $:.include?(load_path)
          else
            LockOMotion.warn "#{call}\nrequires #{absolute_path}", :red
          end
          return
        end
      end

      if path.match(/^\//) && File.exists?(path)
        register_dependency call, path
      else
        LockOMotion.warn "Could not resolve dependency \"#{path}\"\nrequired from #{call}", :red
        raise LoadError, "cannot load such file -- #{path}"
      end
    end

  private

    def register_dependency(call, absolute_path)
      ((@dependencies[call] ||= []) << absolute_path).uniq!
    end

    def setup(&block)
      @files = []
      @dependencies = {}
      @ignored_requires = []

      Thread.current[:lotion_app] = self
      Kernel.instance_eval &hook
      Object.class_eval &hook

      Bundler.require :lotion
      require "colorize", true
      LockOMotion.default_files.select{|x| x.last}.each do |default_file|
        require default_file.first
      end
      yield self if block_given?
      require File.expand_path(USER_LOTION) if File.exists?(USER_LOTION)

      Kernel.instance_eval &unhook
      Object.class_eval &unhook
      Thread.current[:lotion_app] = nil

      bundler = @dependencies.delete("BUNDLER") || []
      gem_lotion = @dependencies.delete("GEM_LOTION") || []
      user_lotion = @dependencies.delete("USER_LOTION") || []
      default_files = LockOMotion.default_files.select{|x| !x.last}.collect(&:first)

      gem_lotion.each do |file|
        default_files.each do |default_file|
          (@dependencies[default_file] ||= []) << file
        end
      end
      (bundler + user_lotion).each do |file|
        @dependencies[file] ||= []
        @dependencies[file] = default_files + @dependencies[file]
      end

      @files = (default_files + gem_lotion.sort + bundler.sort + (@dependencies.keys + @dependencies.values).flatten.sort + user_lotion.sort + @app.files).uniq
      @app.files = @files
      @app.files_dependencies @dependencies
      write_lotion
    end

    def hook
      @hook ||= proc do
        def require_with_catch(path, internal = false)
          return if LockOMotion.skip?(path)
          if mock_path = LockOMotion.mock_path(path)
            path = mock_path
            internal = false
          end
          if caller[0].match(/^(.*\.rb)\b/)
            Thread.current[:lotion_app].dependency $1, path, internal
          end
          begin
            verbose = $VERBOSE
            $VERBOSE = nil if mock_path
            begin
              require_without_catch path
            rescue LoadError
              if gem_path = LockOMotion.gem_paths.detect{|x| File.exists? "#{x}/#{path}"}
                $:.unshift gem_path
                require_without_catch path
              end
            end
          ensure
            $VERBOSE = verbose
          end
        end
        alias :require_without_catch :require
        alias :require :require_with_catch
      end
    end

    def unhook
      @unhook ||= proc do
        alias :require :require_without_catch
        undef :require_with_catch
        undef :require_without_catch
      end
    end

    end



  end
end