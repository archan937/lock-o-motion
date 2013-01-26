require "fileutils"
require "lock-o-motion/version"

module LockOMotion
  extend self

  def install
    `bundle install --path vendor/motion/tmp --without default development test && bundle install --system --without ''`
    Dir["vendor/motion/tmp/ruby/*/gems/*"].each do |dir|
      FileUtils.mv dir, "vendor/motion" unless File.exists?("#{dir}/lib/motion")
    end
    FileUtils.rm_rf "vendor/motion/tmp"
  end

  def setup
    unless defined?(Motion::Project::Config)
      raise "This file must be required within a RubyMotion project Rakefile."
    end
    Motion::Project::App.setup do |app|
      Dir["vendor/motion/*/lib/**/*.rb"].each do |file|
        app.files.unshift(file).uniq!
      end
    end
  end

end