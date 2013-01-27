class Object
  def require(path)
    puts " [warning] app.require #{path.inspect}" if Lotion.require?(path)
  end
end