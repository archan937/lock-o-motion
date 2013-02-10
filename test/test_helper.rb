require "rubygems"
require "bundler"

require "minitest/unit"
require "minitest/autorun"

Bundler.require :gem_default, :gem_test

def silence(&block)
  Kernel.module_eval do
    alias :original_puts :puts
    def puts(message); end
  end
  block.call
  Kernel.module_eval do
    alias :puts :original_puts
    undef :original_puts
  end
end