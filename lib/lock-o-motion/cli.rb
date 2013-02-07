require "bundler"
require "pry"
require "thor"
require "rich/support/core/string/colorize"
require "lock-o-motion"

module LockOMotion
  class CLI < Thor

    class Error < StandardError; end

    default_task :console

    desc "console", "Start Pry console with LockOMotion required gems"
    def console
      Bundler.require :default, :lotion
      puts "Loading LockOMotion development environment"
      Pry.start
    end

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `lotion help`."
    end

  end
end