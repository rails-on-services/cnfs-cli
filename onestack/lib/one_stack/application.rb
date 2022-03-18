# frozen_string_literal: true

module OneStack
  class << self
    def application() = SolidApp.application

    def config() = SolidApp.config
  end

  class Application < SolidApp::Application
    config.before_initialize do |config|

      config.operator_names = %w[builders configurators provisioners runtimes]

      config.target_names = %w[images plans playbooks services]

      config.generic_names = %w[dependencies providers resources registries repositories users]

      config.component_names = %w[component segment_root]

      config.support_names = %w[context definitions context_component runtime_service provisioner_resource]

      config.asset_names = (config.operator_names + config.target_names + config.generic_names).freeze

      # The model class list for which tables will be created in the database
      config.model_names = (config.asset_names + config.component_names + config.support_names).map(&:singularize).freeze
    end

    config.after_initialize do |config|
      config.env.key_prefix ||= 'OS_KEY'
      config.env.key_prefix = config.env.key_prefix.upcase
      config.paths.segments ||= 'segments'
      config.paths.src ||= 'src'
      config.paths.transform_values! { |path| path.is_a?(Pathname) ? path : root.join(path) }

      # Set values for component selection based on any user defined ENVs
      config.segments.each do |key, values|
        env_key = "#{config.env_base}#{values[:env] || key}".upcase
        values[:env_value] = ENV[env_key]
      end

      # Set Command Options
      config.command_options = config.segments.dup.transform_values! do |opt|
        { desc: opt[:desc], aliases: opt[:aliases], type: :string }
      end
    end

    class Configuration < SolidApp::Application::Configuration
      def xb() = 'tuff'
    end
  end
end
