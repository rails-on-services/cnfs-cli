# frozen_string_literal: true

module Cnfs::Commands::Application
  module Backend::Generate::Compose

    def self.included(base)
      base.include Cnfs::Commands::Compose
      base.on_execute :generate_service_manifests
      base.after_execute :generate_compose_env
    end

    def generate_service_manifests
      # Iterate over every defined resource
      config.platform.application.backend.resources.each do |res|
        name = res.class.name.split('::').last
        # Skip any resource that has a generate command class defined, e.g. Rails
        next if self.class.constants.include?(name.to_sym)
        # Look for a corresponding generator class
        generator_class = "#{generator_namespace('Ext', name)}::Service"
        if not Object.const_defined?(generator_class)
          output.puts "WARN: no generator class for #{name}. Should be defined at #{generator_class}"
          next
        end
        # binding.pry
        generator_class.constantize.new([], manual_options(res.name)).invoke_all
      end
    end


    def manual_options(name)
      options.merge(values: config.platform.application.backend.send(name), service: name,
                    project_dir: config.platform.root, orchestrator: config.orchestrator)
    end

    def generate_compose_env
      generator_base = generator_namespace('Ext', 'Compose')
      "#{generator_base}::Env".constantize.new([], compose_env_options).invoke_all
    end

    def compose_env_options
      options.merge(
        # values: platform,
        project_dir: config.platform.root,
        compose_dir: compose_dir,
        compose_file: compose_file,
        compose: {
          project_name: compose_project_name,
          file: Dir["#{config.platform.path_for(:deployments)}/**/*.yml"].join(':')
        }
      )
    end
  end
end
