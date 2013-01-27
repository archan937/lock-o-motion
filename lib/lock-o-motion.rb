require "fileutils"
require "yaml"

require "lock-o-motion/app"
require "lock-o-motion/version"

module LockOMotion
  extend self

  class Error < StandardError; end

  CONFIG = "lotion"
  GEMS_DIR = ".lotion"

  def configure
    FileUtils.rm CONFIG if File.exists?(CONFIG)
    FileUtils.rm_rf GEMS_DIR if File.exists?(GEMS_DIR)
    `bundle install --path #{GEMS_DIR} --without default development test`
    `bundle install --without '' --system`
    File.open(CONFIG, "w") do |config|
      config << {
        :gems => Dir["#{GEMS_DIR}/ruby/*/gems/*"].collect{|x| x.gsub(/.*\//, "")}
      }.to_yaml
    end
    FileUtils.rm_rf GEMS_DIR
  end

  def setup(&block)
    Bundler.require :lotion
    Motion::Project::App.setup do |app|
      LockOMotion::App.new(app).setup &block
    end
  end

end

unless defined?(Lotion)
  Lotion = LockOMotion
end