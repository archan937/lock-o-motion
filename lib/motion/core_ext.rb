class Object

  def require(*args, &block)
  end

end

class Class

  def class_eval(*args, &block)
    Lotion.warn name, :class_eval, caller
  end

  def delegate(*args, &block)
    to = args.pop
    args.each do |method|
      send :define_method, method do |*args, &block|
        send(to).send(method, *args, &block)
      end
    end
  end

end