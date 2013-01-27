module Lotion

  def self.required
    @required ||= []
  end

  def self.require?(path)
    return false if required.include? path
    required.push path
    base_path = path.gsub(/\.(bundle|rb)$/, "")
    Lotion::LOAD_PATHS.none? do |load_path|
      return false if File.exists?("#{load_path}/#{base_path}.bundle")
      Lotion::REQUIRED.include?("#{load_path}/#{base_path}.rb")
    end
  end

end