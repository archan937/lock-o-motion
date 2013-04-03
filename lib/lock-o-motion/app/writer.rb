module LockOMotion
  class App
    module Writer

    private

      def write_lotion
        FileUtils.rm GEM_LOTION if File.exists?(GEM_LOTION)
        File.open(GEM_LOTION, "w") do |file|
          file << <<-RUBY_CODE.gsub("            ", "")
            module Lotion
              FILES = #{pretty_inspect @files, 2}
              DEPENDENCIES = #{pretty_inspect @dependencies, 2}
              IGNORED_REQUIRES = #{pretty_inspect @ignored_requires, 2}
              MOCKS_DIRS = #{pretty_inspect LockOMotion.mocks_dirs, 2}
              LOAD_PATHS = #{pretty_inspect $:, 2}
              GEM_PATHS = #{pretty_inspect LockOMotion.gem_paths, 2}
              REQUIRED = #{pretty_inspect $", 2}
            end
          RUBY_CODE
        end
      end

      def pretty_inspect(object, indent = 0)
        if object.is_a?(Array)
          entries = object.collect{|x| "  #{pretty_inspect x, indent + 2}"}
          return "[]" if entries.empty?
          entries.each_with_index{|x, i| entries[i] = "#{x}," if i < entries.size - 1}
          ["[", entries, "]"].flatten.join "\n" + (" " * indent)
        elsif object.is_a?(Hash)
          entries = object.collect{|k, v| "  #{k.inspect} => #{pretty_inspect v, indent + 2}"}
          return "{}" if entries.empty?
          entries.each_with_index{|x, i| entries[i] = "#{x}," if i < entries.size - 1}
          ["{", entries, "}"].flatten.join "\n" + (" " * indent)
        else
          object.inspect
        end
      end

    end
  end
end