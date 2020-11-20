# frozen_string_literal: true

module Project
  class ConsoleController
    include ExecHelper

    def execute
      require 'pry'
      Pry.start(self, prompt: proc { |_obj, _nest_level, _| 'cnfs> ' })
    end

    class << self
      def shortcuts
        { b: Blueprint, e: Environment, k: Key, n: Namespace, p: Provider, r: Repository, s: Service, u: User }
      end
    end

    shortcuts.each_pair do |key, klass|
      define_method("#{key}a") { klass.all }
      define_method("#{key}f") { cache["#{key}f"] ||= klass.first }
      define_method("#{key}l") { cache["#{key}l"] ||= klass.last }
      define_method("#{key}p") { |*attributes| klass.pluck(*attributes) }
      define_method("#{key}fb") { |name| klass.find_by(name: name) }
    end

    def cache
      @cache ||= {}
    end

    def reset_cache
      @cache = nil
    end

    def reload!
      reset_cache
      true
    end

    def r; reload! end

    def a; Cnfs.app end
  end
end
