# frozen_string_literal: true

# Add a CNFS service configuration and optionally create a new service in a CNFS Rails repository
# 1. Modifies the services.yml file at project, env or ns level depending on the options passed in
# 2. Invoke 'rails [plugin] new' to create the service (a template is invoked to modify generated files)
# 3. Add a model class to the SDK to expose this service's models
module Core
  class ServiceGenerator < Thor::Group
    include Thor::Actions
    # include CommonConcern
    argument :project_name
    argument :name
    argument :services_file_path

    # TODO: (later) When revoke with -r option then should go through all configs at all levels and remove
    # the reference(s) to the services
    # At every scope (project, env, ns) add content:
    #   1. default services key
    #   2. the current service stanza
    def services_file
      binding.pry
      content = ERB.new(File.read(template_path)).result(binding)
      if File.exist?(services_file_path)
        # Check for base config
        keys = YAML.load_file(services_file_path).keys
        append_to_file(services_file_path, default_content) unless keys.include?('DEFAULTS')
        # Create new stanza
        append_to_file(services_file_path, content)
        # When revoked, the above line will subtract content; if the file is now empty the next line will remove it
        create_file(services_file_path) if behavior.eql?(:revoke) && File.size(services_file_path).zero?
      else
        create_file(services_file_path, default_content)
        append_to_file(services_file_path, content)
      end
    end

    private

    def default_content
      ERB.new(File.read(x_path.join('default-services.yml.erb'))).result(binding)
    end

    def template_path
      [options.gem, 'services'].compact.each do |file|
        file_path = x_path.join("#{file}.yml.erb")
        break file_path if file_path.exist?
      end
    end

    def x_path
      path = options.keys.select { |k| %w[environment namespace].include?(k) }.join('/')
      views_path.join('files', path)
    end

    def repo() = 'hello'

    def source_paths
      [views_path, views_path.join('templates')]
    end

    def views_path
      @views_path ||= internal_path.join('services')
    end

    def internal_path
      Pathname.new(__dir__)
    end
  end
end
