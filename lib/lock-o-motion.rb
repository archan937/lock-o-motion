require "lock-o-motion/app"
require "lock-o-motion/version"

module LockOMotion
  extend self

  def setup
    LockOMotion::App.new.setup
  end

end

unless defined?(Lotion)
  Lotion = LockOMotion
end