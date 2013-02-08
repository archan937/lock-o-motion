module LockOMotion
  module App
    extend self

    def require(path)
      begin
        Object.require path
      rescue LoadError
        Object.require File.expand_path(path)
      end
    end

  end
end