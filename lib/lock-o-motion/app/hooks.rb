module LockOMotion
  class App
    module Hooks

      APPFILE = File.expand_path("../../app.rb", __FILE__)

      def dependency(call, path, internal = false)
        call = "BUNDLER" if call.match(/\bbundler\b/)
        if call == APPFILE
          call = internal ? "GEM_LOTION" : "USER_LOTION"
        end

        ($: + LockOMotion.gem_paths).each do |load_path|
          if File.exists?(absolute_path = "#{load_path}/#{path}.bundle") ||
             File.exists?(absolute_path = "#{load_path}/#{path}.rb")
            if absolute_path.match(/\.rb$/)
              register_dependency call, absolute_path
              $:.unshift load_path unless $:.include?(load_path)
            else
              LockOMotion.warn "#{call}\nrequires #{absolute_path}", :red
            end
            return
          end
        end

        if path.match(/^\//) && File.exists?(path)
          register_dependency call, path
        else
          LockOMotion.warn "Could not resolve dependency \"#{path}\"\nrequired from #{call}", :red
          raise LoadError, "cannot load such file -- #{path}"
        end
      end

      def autoloaded(mod, name, path)
        register_autoload mod, name, path
      end

      def autoload_path(mod, name)
        (@autoloads[mod.name] || {})[name.to_s]
      end

    private

      def register_dependency(call, absolute_path)
        ((@dependencies[call] ||= []) << absolute_path).uniq!
      end

      def register_autoload(mod, name, path)
        (@autoloads[mod.name] ||= {})[name.to_s] = path
      end

      def hook
        @dependencies = {}
        @autoloads = {}

        Thread.current[:lotion_app] = self

        Kernel.instance_eval &require_hook
        Object.class_eval &require_hook
        Module.class_eval &autoload_hook
        Module.class_eval &const_missing_hook

        yield

        Kernel.instance_eval &require_unhook
        Object.class_eval &require_unhook
        Module.class_eval &autoload_unhook
        Module.class_eval &const_missing_unhook

        @dependencies.delete APPFILE
        Thread.current[:lotion_app] = nil
      end

      def require_hook
        @require_hook ||= proc do
          def require_with_hook(path, internal = false)
            return if LockOMotion.skip?(path)
            if mock_path = LockOMotion.mock_path(path)
              path = mock_path
              internal = false
            end
            if caller[0].match(/^(.*\.rb)\b/)
              Thread.current[:lotion_app].dependency $1, path, internal
            end
            begin
              verbose = $VERBOSE
              $VERBOSE = nil if mock_path
              begin
                require_without_hook path
              rescue LoadError
                if gem_path = LockOMotion.gem_paths.detect{|x| File.exists? "#{x}/#{path}"}
                  $:.unshift gem_path
                  require_without_hook path
                end
              end
            ensure
              $VERBOSE = verbose
            end
          end
          alias :require_without_hook :require
          alias :require :require_with_hook
        end
      end

      def require_unhook
        @require_unhook ||= proc do
          alias :require :require_without_hook
          undef :require_with_hook
          undef :require_without_hook
        end
      end

      def autoload_hook
        @autoload_hook ||= proc do
          def autoload_with_hook(name, path)
            Thread.current[:lotion_app].autoloaded self, name, path
          end
          alias :autoload_without_hook :autoload
          alias :autoload :autoload_with_hook
        end
      end

      def autoload_unhook
        @autoload_unhook ||= proc do
          alias :autoload :autoload_without_hook
          undef :autoload_with_hook
          undef :autoload_without_hook
        end
      end

      def const_missing_hook
        @const_missing_hook ||= proc do
          def const_missing_with_hook(name)
            if path = Thread.current[:lotion_app].autoload_path(self, name)
              require path
              const_get name
            else
              const_missing_without_hook name
            end
          end
          alias :const_missing_without_hook :const_missing
          alias :const_missing :const_missing_with_hook
        end
      end

      def const_missing_unhook
        @const_missing_unhook ||= proc do
          alias :const_missing :const_missing_without_hook
          undef :const_missing_with_hook
          undef :const_missing_without_hook
        end
      end

    end
  end
end