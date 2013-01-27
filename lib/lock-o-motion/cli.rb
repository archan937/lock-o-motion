require "thor"
require "rich/support/core/string/colorize"
require "lock-o-motion"

module LockOMotion
  class CLI < Thor

    class Error < StandardError; end

    default_task :configure

    desc "configure", "Create LockOMotion configuration file"
    def configure
      puts "Creating LockOMotion configuration file ...".yellow
      LockOMotion.configure
    end

    def console
      Bundler.require :defautl, :lotion
      puts "Loading LockOMotion development environment"
      Pry.start
    end

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `lotion help`."
    end

  end
end