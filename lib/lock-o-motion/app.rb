module LockOMotion
  class App
    attr_reader :motion_app

    LOTION = ".lotion.rb"

    def initialize(motion_app)
      @motion_app = motion_app
    end

    def setup
      motion_app.files.concat gem_files
      yield self if block_given?
      motion_app.files.push File.expand_path("lotion.rb") if File.exists?("lotion.rb")
      write_lotion
      motion_app.files.unshift File.expand_path("../../motion/object.rb", __FILE__)
      motion_app.files.unshift File.expand_path("../../motion/lotion.rb", __FILE__)
      motion_app.files.unshift File.expand_path(".lotion.rb")
    end

    def require(path)
      absolute_path = nil
      if $:.detect{|x| File.exists?(absolute_path = "#{x}/#{path.gsub(/\.rb$/, "")}.rb")}
        motion_app.files.push absolute_path
      else
        raise Error, "Could not resolve #{path} for requirement"
      end
    end

  private

    def gem_files
      [].tap do |gem_files|
        YAML.load_file(CONFIG)[:gems].each do |ruby_gem|
          if dir = $:.detect{|load_path| load_path.match /#{ruby_gem}\/lib$/}
            gem_files.concat Dir["#{dir}/**/*.rb"]
          else
            raise Error, "Unable to setup #{ruby_gem}"
          end
        end
      end
    end

    def write_lotion
      FileUtils.rm LOTION if File.exists?(LOTION)
      File.open(LOTION, "w") do |file|
        file << <<-RUBY_CODE
module Lotion
  LOAD_PATHS = [
    #{to_ruby_code $:}
  ]
  REQUIRED = [
    #{to_ruby_code motion_app.files}
  ]
end
RUBY_CODE
      end
    end

    def to_ruby_code(array)
      array.collect{|x| File.expand_path(x).inspect}.join(",\n    ")
    end

  end
end