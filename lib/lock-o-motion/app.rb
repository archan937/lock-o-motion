module LockOMotion
  module App
    extend self

    def require(path)
      call = caller[0].match(/^(.*\.rb)/) && $1
      if call == File.expand_path("../../lock-o-motion.rb", __FILE__)
        call = "BUNDLER"
      end
      Kernel.require path, call
    end

  end
end