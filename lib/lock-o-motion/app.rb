module LockOMotion
  module App
    extend self

    def require(path)
      call = caller[0].match(/^(.*\.rb)/) && $1
      if call == File.expand_path("../../lock-o-motion.rb", __FILE__)
        call = File.expand_path(GEM_LOTION)
      end
      begin
        Kernel.require path, call
      rescue LoadError
        Kernel.require File.expand_path(path), call
      end
    end

  end
end