# frozen_string_literal: true

require 'cnfs/plugin'

module Cnfs
  class Application < Plugin
    require 'cnfs/application/configuration'

    def config() = self.class.config

    def name() = self.class.name.deconstantize.downcase

    class << self
      def config() = @config ||= Configuration.new

      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        super
        Cnfs.app_class = base
      end

      def gem_root() = APP_ROOT
    end

    # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L367
    def initialize!
      config.after_user_config
      self
    end
  end
end
