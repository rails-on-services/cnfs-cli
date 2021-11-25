# frozen_string_literal: true

require 'active_support/ordered_options'

module Cnfs
  class Config
    attr_reader :path, :root_file_id, :root

    def initialize(**options)
      raise StandardError, 'Provide path and root_file_id' unless options.key?(:path) && defined?(:root_file_id)

      @path = options.delete(:path)
      @configurations = options
      after_initialize
      self
    end

    def yield_to_user
      yield self
    end

    # Is this a valid project based on the presence of the root_file_id, e.g. project.yml
    def project
      root.join(root_file_id).exist?
    end

    def root
      @root ||= @path.ascend { |path| break path if path.join(root_file_id).file? } || @path
    end

    def config_home() = @config_home ||= xdg.config_home.join(xdg_name)

    def data_home() = @data_home ||= xdg.data_home.join(xdg_name)

    def xdg_name() = name

    def xdg() = @xdg ||= XDG::Environment.new

    # Reused from railties/lib/rails/application/configuration.rb
    def method_missing(method, *args)
      return if %i[after_initialize after_user_config].include?(method)

      if method.end_with?("=")
        @configurations[:"#{method[0..-2]}"] = args.first
      else
        @configurations.fetch(method) {
          @configurations[method] = ActiveSupport::OrderedOptions.new
        }
      end
    end

    def respond_to_missing?(symbol, *)
      true
    end
  end
end
