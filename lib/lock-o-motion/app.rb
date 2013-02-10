module LockOMotion
  class App

    GEM_LOTION  = ".lotion.rb"
    USER_LOTION =  "lotion.rb"

    def self.setup(app, &block)
      new(app).send :setup, &block
    end

    def initialize(app)
      @app = app
    end

    def require(path)
      Kernel.require path
    end

    def ignore_require(path)
      @ignored_requires << path
    end

    def dependency(call, path)
      call = "BUNDLER" if call.match(/\bbundler\b/)
      call = "CUSTOM"  if call == __FILE__

      ($: + LockOMotion.gem_paths).each do |load_path|
        if File.exists?(absolute_path = "#{load_path}/#{path}.rb") ||
           File.exists?(absolute_path = "#{load_path}/#{path}.bundle")
          if absolute_path.match(/\.rb$/)
            (@dependencies[call] ||= []) << absolute_path
            $:.unshift load_path unless $:.include?(load_path)
          else
            puts "   Warning #{call}\n           requires #{absolute_path}".red
          end
          return
        end
      end

      puts "   Warning Could not resolve dependency \"#{path}\"".red
    end

  private

    def setup(&block)
      @files = []
      @dependencies = {}
      @ignored_requires = []

      Thread.current[:lotion_app] = self
      Kernel.instance_eval &hook
      Object.class_eval &hook

      Bundler.require :lotion
      require "colorize"
      yield self if block_given?

      Kernel.instance_eval &unhook
      Object.class_eval &unhook
      Thread.current[:lotion_app] = nil

      bundler = @dependencies.delete("BUNDLER") || []
      custom  = @dependencies.delete("CUSTOM")  || []
      (bundler + custom).each do |file|
        (@dependencies[file] ||= []).concat default_files
      end

      @files = (default_files + bundler.sort + (@dependencies.keys + @dependencies.values).flatten.sort + custom.sort + @app.files).uniq
      @files << File.expand_path(USER_LOTION) if File.exists?(USER_LOTION)

      @app.files = @files
      @app.files_dependencies @dependencies
      write_lotion
    end

    def hook
      @hook ||= proc do
        def require_with_catch(path)
          return if LockOMotion.skip?(path)
          if caller[0].match(/^(.*\.rb)\b/)
            Thread.current[:lotion_app].dependency $1, path
          end
          begin
            require_without_catch path
          rescue LoadError
            if gem_path = LockOMotion.gem_paths.detect{|x| File.exists? "#{x}/#{path}"}
              $:.unshift gem_path
              require_without_catch path
            end
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

    def default_files
      @default_files ||= [
        File.expand_path("../../motion/core_ext.rb", __FILE__),
        File.expand_path("../../motion/lotion.rb", __FILE__),
        File.expand_path(GEM_LOTION)
      ]
    end

    def write_lotion
      FileUtils.rm GEM_LOTION if File.exists?(GEM_LOTION)
      File.open(GEM_LOTION, "w") do |file|
        file << <<-RUBY_CODE.gsub("          ", "")
          module Lotion
            FILES = #{pretty_inspect @files, 2}
            DEPENDENCIES = #{pretty_inspect @dependencies, 2}
            IGNORED_REQUIRES = #{pretty_inspect @ignored_requires, 2}
            LOAD_PATHS = #{pretty_inspect $:, 2}
            GEM_PATHS = #{pretty_inspect LockOMotion.gem_paths, 2}
            REQUIRED = #{pretty_inspect $", 2}
          end
        RUBY_CODE
      end
    end

    def pretty_inspect(object, indent = 0)
      if object.is_a?(Array)
        entries = object.collect{|x| "  #{pretty_inspect x, indent + 2}"}
        return "[]" if entries.empty?
        entries.each_with_index{|x, i| entries[i] = "#{x}," if i < entries.size - 1}
        ["[", entries, "]"].flatten.join "\n" + (" " * indent)
      elsif object.is_a?(Hash)
        entries = object.collect{|k, v| "  #{k.inspect} => #{pretty_inspect v, indent + 2}"}
        return "{}" if entries.empty?
        entries.each_with_index{|x, i| entries[i] = "#{x}," if i < entries.size - 1}
        ["{", entries, "}"].flatten.join "\n" + (" " * indent)
      else
        object.inspect
      end
    end

  end
end