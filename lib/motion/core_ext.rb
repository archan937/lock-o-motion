module Kernel
  def require(*args, &block)
    Lotion.require args.first
  end
end

class Module
  def class_eval(*args, &block)
    Lotion.warn name, :class_eval, caller
  end
  def module_eval(*args, &block)
    Lotion.warn name, :module_eval, caller
  end
end

class Class
  def delegate(*args, &block)
    to = args.pop
    args.each do |method|
      send :define_method, method do |*args, &block|
        send(to).send(method, *args, &block)
      end
    end
  end
end

class Object
  def require(*args, &block)
    Lotion.require args.first
  end
  def instance_eval(*args, &block)
    Lotion.warn self.class.name, :instance_eval, caller
  end
end