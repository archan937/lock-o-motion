require "thor"
require "rich/support/core/string/colorize"
require "lock-o-motion"

module LockOMotion
  class CLI < Thor

    class Error < StandardError; end
    
    default_task :install

    desc "install", "Installs Ruby gems within vendor/motion"
    def install
      LockOMotion.install
    end

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `lotion help`."
    end

  end
end