module Lotion
  extend self

  def require(path, _caller = nil)
    return if required[path]
    required[path] = true

    if absolute_path = resolve(path)
      unless (IGNORED_REQUIRES + REQUIRED).include?(absolute_path)
        warn [
          "Called `require \"#{path}\"` from",
          _caller ? derive_caller(_caller) : '(unspecified)',
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
        "Called `#{object}.#{method}` from\n#{derive_caller(caller, false)}"
      end
    end
    puts "   Warning #{message.gsub("\n", "\n           ")}".yellow
  end

private

  def derive_caller(caller, identical = true)
    if caller.empty?
      "<unknown path>"
    else
      file, line = *caller[0].match(/^(.*\.rb):(\d+)/).captures
      resolved = resolve file, identical
      case resolved
      when String
        "#{resolved}:#{line}"
      when Array
        if resolved.size == 1
          "#{resolved[0]}:#{line}"
        else
          "either " + resolved.collect{|x| "#{x}:#{line}"}.join("\n    or ")
        end
      else
        "#{file || caller[0].match(/^(.*\.\w+):/).captures[0]}:#{line}"
      end
    end
  end

  def required
    @required ||= {}
  end

  def resolve_paths
    @resolve_paths ||= MOCKS_DIRS + LOAD_PATHS + GEM_PATHS
  end

  def resolve(path, identical = true)
    if path.match /^\//
      path
    else
      (resolve_paths).each do |load_path|
        if File.exists?(absolute_path = "#{load_path}/#{path}.bundle") ||
           File.exists?(absolute_path = "#{load_path}/#{path}.rb") ||
           File.exists?(absolute_path = "#{load_path}/#{path}")
          return (absolute_path if absolute_path.match(/\.rb$/))
        end
      end
      if !identical && path.match(/\.rb$/) && !(matches = (FILES + REQUIRED).uniq.select{|file| file.match(/\/#{path}$/)}).empty?
        matches
      end
    end
  end

end
