require "lock-o-motion/version"

module LockOMotion
  extend self

  def setup
    Motion::Project::App.setup do |app|
      dependencies = catch_file_dependencies do
        Bundler.require :lotion
      end
      app.files.unshift File.expand_path("../motion/core_ext.rb", __FILE__)
      app.files.concat (dependencies.keys + dependencies.values).flatten.uniq.sort
      app.files.push File.expand_path("lotion.rb") if File.exists?("lotion.rb")
      app.files_dependencies dependencies
    end
  end

private

  def catch_file_dependencies(&block)
    Thread.current[:catched_file_dependencies] = {}

    Object.class_eval do
      def require_with_catch(path)
        call = caller[0].match(/^(.*\.rb)/).captures[0]
        file = "#{path.gsub(/\.rb$/, "")}.rb"
        if dir = $:.detect{|x| File.exists?("#{x}/#{file}")}
          (Thread.current[:catched_file_dependencies][call] ||= []) << "#{dir}/#{file}"
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

end

unless defined?(Lotion)
  Lotion = LockOMotion
end