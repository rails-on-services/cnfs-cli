# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# 1. Modifies the services.yml file at project, env or ns level depending on the options passed in
# 2. Invoke 'rails [plugin] new' to create the service (a template is invoked to modify generated files)
# 3. Add a model class to the SDK to expose this service's models
module Rails
  class ServiceGenerator < Thor::Group
    include Thor::Actions
    include GeneratorConcern
    # argument :repository
    argument :service
    # argument :project_name
    # argument :service_name

    def service
      @repository = service.repository
      send("service_#{behavior}")
    end

    no_commands do
      def service_revoke
        inside('services') { empty_directory(service.name) }
      end

      # Create the service
      def service_invoke
        # base_env = { repo_name: repository.name, repo_path: '../..', name: full_service_name }
        # with_context('service/generator.rb', 'services', full_service_name, base_env) do |env, exec_ary|
        base_env = { repo_name: repository.name, repo_path: '../..', name: service.name }
        with_context('service/generator.rb', 'services', service.name, base_env) do |env, exec_ary|
      binding.pry
          system(env, exec_ary.join(' '))
        end
      end
    end

    # Create a module and base classes for this service in the SDK and require it at load time
    def sdk_service_model
      template('sdk_model.rb.erb', "#{sdk_lib_path}/models/#{service.name}.rb")
      append_file "#{sdk_lib_path}/models.rb", <<~RUBY
        require_relative 'models/#{service.name}'
      RUBY
    end

    # TODO: This should not be necessary
    # Figure out how to name the SDK and Core gems appropriately
    # def gemspec_content
    #   return unless options.type.eql?('plugin')
    #   gemspec = "services/#{name}/#{name}.gemspec"
    #   gsub_file gemspec, '  spec.name        = "', '  spec.name        = "cnfs-'
    # end

    private

    # def full_service_name
    #   [namespace, service.name].compact.join('_')
    # end

    def sdk_lib_path
      # lib_path.join('sdk/lib', [namespace, 'sdk'].compact.join('_'))
      lib_path.join('sdk/lib/sdk')
    end

    # def namespace
    #   @namespace ||= nil # Cnfs.repository.namespace
    # end

    def lib_path
      Pathname.new(destination_root).join('lib')
    end

    def source_paths
      [views_path, views_path.join('templates')]
    end

    def views_path
      @views_path ||= internal_path.join('service')
    end

    def internal_path
      Pathname.new(__dir__)
    end
  end
end
