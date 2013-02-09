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
      write_lotion
    end
  end

private

  def catch_files_dependencies(&block)
    Thread.current[:catched_files_dependencies] = {}

    Object.class_eval do
      def require_with_catch(path)
        hash = Thread.current[:catched_files_dependencies]

        if caller[0].match(/^(.*\.rb)/)
          call = ($1 == APP_FILE ? File.expand_path(GEM_LOTION) : $1)
          file = "#{path.gsub(/\.rb$/, "")}.rb"
          if load_path = $:.detect{|x| File.exists?("#{x}/#{file}")}
            if hash.empty? && File.exists?(USER_LOTION)
              hash[File.expand_path(USER_LOTION)] = [call]
            end
            (hash[call] ||= []) << "#{load_path}/#{file}"
          end
        end

        require_without_catch path
      end
      alias :require_without_catch :require
      alias :require :require_with_catch
    end

    block.call

    Object.class_eval do
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

  def write_lotion
    FileUtils.rm GEM_LOTION if File.exists?(GEM_LOTION)
    File.open(GEM_LOTION, "w") do |file|
      file << <<-RUBY_CODE.gsub("        ", "")
        module Lotion
          LOAD_PATHS = [
            #{to_ruby_code $:}
          ]
          REQUIRED = [
            #{to_ruby_code $"}
          ]
        end
      RUBY_CODE
    end
  end

  def to_ruby_code(array)
    array.collect{|x| File.expand_path(x).inspect}.join(",\n    ")
  end

end

unless defined?(Lotion)
  Lotion = LockOMotion
end