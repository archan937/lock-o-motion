module Kernel
  def require(*args, &block)
    Lotion.require args.first, caller
  end
end

class Module
  alias :original_class_eval :class_eval
  def class_eval(*args, &block)
    if block_given?
      original_class_eval &block
    else
      Lotion.warn name, :class_eval, caller
    end
  end
  alias :original_module_eval :module_eval
  def module_eval(*args, &block)
    if block_given?
      original_module_eval &block
    else
      Lotion.warn name, :module_eval, caller
    end
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
    Lotion.require args.first, caller
  end
  alias :original_instance_eval :instance_eval
  def instance_eval(*args, &block)
    if block_given?
      original_instance_eval &block
    else
      Lotion.warn self.class.name, :instance_eval, caller
    end
  end
end
