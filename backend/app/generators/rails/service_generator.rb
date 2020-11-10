# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# 1. Modifies the services.yml file at project, env or ns level depending on the options passed in
# 2. Invoke 'rails [plugin] new' to create the service (a template is invoked to modify generated files)
# 3. Add a model class to the SDK to expose this service's models
module Rails
  class ServiceGenerator < Thor::Group
    include Thor::Actions
    include CommonConcern
    argument :project_name
    argument :name

    # TODO: If the base service definition already exists then just add an inherited stanza
    # TODO: (later) When revoke with -r option then should go through all configs at all levels and remove
    # the reference(s) to the services
    # TODO: Maybe this part should be in the cli gem and only the repo creating stuff is in
    def services_file
      content = ERB.new(File.read(template_path)).result(binding)
      if File.exist?(options.services_file)
        append_to_file(options.services_file, content)
        # When revoked, the above line will subtract content; if the file is now empty the next line will remove it
        create_file(options.services_file) if behavior.eql?(:revoke) and File.size(options.services_file).zero?
      else
        create_file(options.services_file, content)
      end
    end

    def repository_service
      return unless options.repository

      service_gem
      sdk_service_model
    end

    private

    def template_path
      path = options.keys.select { |k| %w[environment namespace].include?(k) }.join('/')
      "#{views_path}/files/#{path}/services.yml.erb"
    end

    def repo; 'hello' end


    def service_gem
      if behavior.eql? :revoke
        inside('services') { empty_directory(name) }
        return
      end

      raise Cnfs::Error, "service #{name} already exists" if Dir.exist?("#{destination_root}/services/#{name}")

      # with_context('service/generator.rb', "#{project_name}-#{name}", 'services') do |env, exec_ary|
      #   system(env, exec_ary.join(' '))
      # end
    end

    # TODO: This should not be necessary
    # Figure out how to name the SDK and Core gems appropriately
    # def gemspec_content
    #   return unless options.type.eql?('plugin')

    #   gemspec = "services/#{name}/#{name}.gemspec"
    #   gsub_file gemspec, '  spec.name        = "', '  spec.name        = "cnfs-'
    # end

    def sdk_service_model
      create_file "#{sdk_lib_path}/models/#{name}.rb", <<~RUBY
        # frozen_string_literal: true

        module #{platform_name.split('_').collect(&:capitalize).join}
          module #{name.split('_').collect(&:capitalize).join}
            class Client < Ros::Platform::Client; end
            class Base < Ros::Sdk::Base; end

            class Tenant < Base; end
          end
        end
      RUBY

      append_file "#{sdk_lib_path}/models.rb", <<~RUBY
        require '#{platform_name}_sdk/models/#{name}.rb'
      RUBY
    end

    def sdk_lib_path
      lib_path.join('sdk/lib', "#{platform_name}_sdk")
    end

    # TODO: Should this rather be passed in or taken from teh project name itself
    def platform_name
      File.basename(Dir["#{lib_path.join('sdk')}/*.gemspec"].first).delete_suffix('_sdk.gemspec')
    end

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
