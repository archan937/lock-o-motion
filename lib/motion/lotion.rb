module Lotion
  extend self

  def warn(object, method, caller)
    puts "   Warning Called #{object}.#{method} from #{resolve caller[0]}".yellow
  end

private

  def resolve(path)
    if path.match /^\//
      path
    else
      path = path.gsub(/\.rb.*$/, ".rb")
      LOAD_PATHS.each do |load_path|
        if File.exists?(absolute_path = "#{load_path}/#{path}")
          return absolute_path
        end
      end
      nil
    end
  end

end