require "colorize"
require "lock-o-motion/app"
require "lock-o-motion/version"

module LockOMotion
  extend self

  APP_FILE    = File.expand_path("../lock-o-motion/app.rb", __FILE__)
  GEM_LOTION  = ".lotion.rb"
  USER_LOTION = "lotion.rb"

  def setup
    Motion::Project::App.setup do |app|
      files_dependencies = catch_files_dependencies do
        Bundler.require :lotion
        LockOMotion::App.require "colorize"
        yield LockOMotion::App if block_given?
      end
      app.files.concat default_files + (files_dependencies.keys + files_dependencies.values).flatten.uniq.sort
      app.files_dependencies files_dependencies
      write_lotion files_dependencies
    end
  end

  def skipped?(path)
    !!%w(pry).detect{|x| path.match %r{\b#{x}\b}}.tap do |file|
      puts "   Warning Skipped '#{file}' requirement".yellow if file
    end
  end

private

  def catch_files_dependencies(&block)
    Thread.current[:catched_files_dependencies] = {}

    Kernel.instance_eval do
      def require_with_catch(path, call = nil)
        return if LockOMotion.skipped?(path)
        hash = Thread.current[:catched_files_dependencies]

        if call || caller[0].match(/^(.*\.rb)/)
          call ||= $1
          file = "#{path.gsub(/\.rb$/, "")}.rb"
          if !call.match(/\bbundler\b/) && load_path = $:.detect{|x| File.exists?("#{x}/#{file}")}
            (hash[call] ||= []) << "#{load_path}/#{file}"
          end
        end

        require_without_catch path
      end
      alias :require_without_catch :require
      alias :require :require_with_catch
    end

    block.call

    Kernel.instance_eval do
      alias :require :require_without_catch
      undef :require_with_catch
      undef :require_without_catch
    end

    Thread.current[:catched_files_dependencies].tap do |dependencies|
      Thread.current[:catched_files_dependencies] = nil
    end
  end

  def default_files
    [
      File.expand_path("../motion/core_ext.rb", __FILE__),
      File.expand_path("../motion/lotion.rb", __FILE__),
      (File.expand_path(USER_LOTION) if File.exists?(USER_LOTION)),
      File.expand_path(GEM_LOTION)
    ].compact
  end

  def write_lotion(dependencies)
    FileUtils.rm GEM_LOTION if File.exists?(GEM_LOTION)
    File.open(GEM_LOTION, "w") do |file|
      file << <<-RUBY_CODE.gsub("        ", "")
        module Lotion
          LOAD_PATHS = #{pretty_inspect $:, 2}
          REQUIRED = #{pretty_inspect $", 2}
          DEPENDENCIES = #{pretty_inspect dependencies, 2}
        end
      RUBY_CODE
    end
  end

  def pretty_inspect(object, indent = 0)
    if object.is_a?(Array)
      [
        "[",
        object.collect{|x| "  #{pretty_inspect x, indent + 2},"},
        "]"
      ].flatten.join "\n" + (" " * indent)
    elsif object.is_a?(Hash)
      [
        "{",
        object.collect{|k, v| "  #{k.inspect} => #{pretty_inspect v, indent + 2},"},
        "}"
      ].flatten.join "\n" + (" " * indent)
    else
      object.inspect
    end
  end

end

unless defined?(Lotion)
  Lotion = LockOMotion
end