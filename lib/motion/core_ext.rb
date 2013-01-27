class Object
  def require(path)
    puts " [warning] app.require #{path.inspect}" if Lotion.require?(path)
  end
end

class Class
  def delegate(*args)
    to = args.pop
    args.each do |method|
      send :define_method, method do |*args, &block|
        send(to).send(method, *args, &block)
      end
    end
  end
end