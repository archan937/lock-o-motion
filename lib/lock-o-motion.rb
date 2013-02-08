require "lock-o-motion/version"

module LockOMotion
  extend self

  LOTION = ".lotion.rb"

  def setup
    Motion::Project::App.setup do |app|
      dependencies = catch_file_dependencies do
        Bundler.require :lotion
      end
      app.files.unshift File.expand_path("../motion/core_ext.rb", __FILE__)
      app.files.concat (dependencies.keys + dependencies.values).flatten.uniq.sort
      app.files.push File.expand_path("lotion.rb") if File.exists?("lotion.rb")
      app.files_dependencies dependencies
      write_lotion
    end
  end

private

  def catch_file_dependencies(&block)
    Thread.current[:catched_file_dependencies] = {}

    Object.class_eval do
      def require_with_catch(path)
        if caller[0].match(/^(.*\.rb)/)
          call = $1
          file = "#{path.gsub(/\.rb$/, "")}.rb"
          if dir = $:.detect{|x| File.exists?("#{x}/#{file}")}
            (Thread.current[:catched_file_dependencies][call] ||= []) << "#{dir}/#{file}"
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

    Thread.current[:catched_file_dependencies].tap do |dependencies|
      Thread.current[:catched_file_dependencies] = nil
    end
  end

  def write_lotion
    FileUtils.rm LOTION if File.exists?(LOTION)
    File.open(LOTION, "w") do |file|
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