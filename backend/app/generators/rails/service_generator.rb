# frozen_string_literal: true

# Creates a new service in a CNFS Rails repository
module Rails
  class ServiceGenerator < Thor::Group
    include Thor::Actions
    argument :name

    def generate_service_file
      FileUtils.touch(options.services_file)
      # TODO: update the service definition; rails is just boilerplate
      append_to_file(options.services_file, rails)
    end

    def generate
      if behavior.eql? :revoke
        inside('services') { empty_directory(name) }
        return
      end

      raise Cnfs::Error, "service #{name} already exists" if Dir.exist?("#{destination_root}/services/#{name}")

      exec_string = ['rails new']
      exec_string = ['rails plugin new', '--full --dummy-path=spec/dummy'] if options.type.eql?('plugin')  
      # TODO: These strings should be external configuration values
      # exec_string.append('--full --dummy-path=spec/dummy') if options.type.eql?('plugin')
      exec_string.append('--api -G -S -J -C -T -M --skip-turbolinks --database=postgresql --skip-active-storage')

      # If the project has a service generator then prefer that over the internal generator
      generator_name = 'service/generator.rb'
      relative_path = internal_path.to_s.delete_prefix("#{Cnfs::Cli::Backend.gem_root}/app/")
      user_path = Cnfs.project_root.join(Cnfs.paths.lib).join(relative_path)
      exec_path = user_path.join(generator_name).exist? ? user_path : internal_path
      exec_string.append('-m', exec_path.join(generator_name), name)

      env = base_env.merge(gem_env).transform_keys!{ |key| "cnfs_#{key}".upcase }
      puts env
      puts exec_string.join(' ')
      # inside('services') { system(env, exec_string.join(' ')) }
    end

    # TODO: This should not be necessary
    # Figure out how to name the SDK and Core gems appropriately
    def gemspec_content
      return unless options.plugin

      gemspec = "services/#{name}/#{name}.gemspec"
      gsub_file gemspec, '  spec.name        = "', '  spec.name        = "cnfs-'
    end

    def sdk_content
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

    private

    def base_env
      {
        repository_name: options.repository, # Cnfs.repository_root.split.last.to_s,
        code_type: 'service',
        service_name: name,
        service_type: options.type, # plugin ? 'plugin' : 'application',
        app_dir: options.type.eql?('plugin') ? 'spec/dummy/' : '.'
      }
    end

    def gem_env
      return {} unless options.gem_source

      gem_repo, gem_path, gem_name = options.gem_source.split('/')
      gem_path ||= 'services'
      gem_name ||= name
      path = [gem_repo, gem_path, gem_name].join('/')

      # env[:wrapped_repository_path] = '../../..'
      # env[:wrapped_repository_name] = gem_repo
      # env[:wrapped_service_name] = gem_name
      {
        gem_repository_path: '../../..',
        gem_repo: gem_repo,
        gem_name: gem_name
      }
    end

    def rails
      "cognito: &base_service\n  type: Service::Rails\n  config:\n    depends_on:\n      - wait\n"
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
