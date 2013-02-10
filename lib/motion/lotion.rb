module Lotion
  extend self

  def require(path, caller)
    return if required.include? path
    required << path

    if absolute_path = resolve(path)
      unless (IGNORED_REQUIRES + REQUIRED).include?(absolute_path)
        warn [
          "Called `require \"#{path}\"` from",
          derive_caller(caller),
          "Add within Lotion.setup block: ".yellow + "app.require \"#{path}\"".green
        ].join("\n")
      end
    else
      raise LoadError, "cannot load such file -- #{path}"
    end
  end

  def warn(*args)
    message = begin
      if args.size == 1
        args.first
      else
        object, method, caller = *args
        "Called `#{object}.#{method}` from\n#{derive_caller(caller)}"
      end
    end
    puts "   Warning #{message.gsub("\n", "\n           ")}".yellow
  end

private

  def derive_caller(caller)
    return "<unknown path>" if caller.empty?
    file, line = *caller[0].match(/^(.*\.rb):(\d+)/).captures
    "#{resolve file}:#{line}"
  end

  def required
    @required ||= []
  end

  def resolve(path)
    if path.match /^\//
      path
    else
      (LOAD_PATHS + GEM_PATHS).each do |load_path|
        if File.exists?(absolute_path = "#{load_path}/#{path}.bundle") ||
           File.exists?(absolute_path = "#{load_path}/#{path}.rb") ||
           File.exists?(absolute_path = "#{load_path}/#{path}")
          return (absolute_path if absolute_path.match(/\.rb$/))
        end
      end
      nil
    end
  end

end