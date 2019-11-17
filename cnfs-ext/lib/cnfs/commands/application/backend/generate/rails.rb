# frozen_string_literal: true

module Cnfs::Commands::Application
    module Backend::Generate::Rails

      def self.included(base)
        base.on_execute :generate_rails_manifests
      end

      def generate_rails_manifests
        generator_base = generator_namespace('Ext', 'Rails')
        "#{generator_base}::CommonEnv".constantize.new([], options.merge(values: config.platform)).invoke_all
        rails.settings.units.each_pair do |key, values|
          next if values.disabled
          g = "#{generator_base}::Service".constantize.new([], generator_options.merge(service: key, config: values))
          g.invoke_all
        end
      end

      def generator_options
        options.merge(values: rails, project_dir: config.platform.root, orchestrator: config.orchestrator)
      end

      def rails; config.platform.application.backend.rails end

      # NOTE: image_prefix is specific to the image_type
      # def image_prefix; config.dig(:image, :build_args, :rails_env) end
    end
end
