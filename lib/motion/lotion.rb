module Lotion
  extend self

  def warn(*args)
    message = begin
      if args.size == 1
        args.first
      else
        object, method, caller = *args
        "Called #{object}.#{method} from #{resolve caller[0]}"
      end
    end
    puts "   Warning #{message}".yellow
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