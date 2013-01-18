require "fileutils"
require "lock-o-motion/version"

module LockOMotion
  extend self

  def setup
    unless defined?(Motion::Project::Config)
      raise "This file must be required within a RubyMotion project Rakefile."
    end

    Motion::Project::App.setup do |app|
      Dir["vendor/motion/*/lib/**/*.rb"].each do |file|
        app.files.unshift file
      end
    end
  end

  # TODO: Provide as Rake task
  def bundle
    `bundle install --path vendor/motion/tmp --without development test`
    Dir["vendor/motion/tmp/ruby/*/gems/*"].each do |dir|
      FileUtils.mv dir, "vendor/motion"
    end
    FileUtils.rm_rf "vendor/motion/tmp"
  end

end