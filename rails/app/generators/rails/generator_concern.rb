# frozen_string_literal: true

# Shared methods for Rails::ServiceGnerator and Rails::RepositoryGenerator
module Rails
  module GeneratorConcern
    extend ActiveSupport::Concern

    included do
      private

      # rails_generator_path: the template that will be invoked with the call to rails -m
      # create_path: the path where the gem/service will be created; service: 'services', repo: 'lib'
      # service_name: the name of the application or plugin; service: 'iam', repo: 'core'
      # base_envs: passed in from the generator: repository or service
      def with_context(rails_generator_path, create_path, service_name, base_envs)
        source_envs = source_envs(base_envs)
        envs = base_envs.merge(source_envs).merge(service_envs)
        envs.transform_keys! { |key| "cnfs_#{key}".upcase }

        # Create the rails exec string
        exec_ary = base_exec.append(rails_template_string(rails_generator_path), service_name)

        Cnfs.logger.info(envs.map { |k, v| "#{k}=#{v}" })
        Cnfs.logger.info(exec_ary.join(' '))

        inside(create_path) do
          binding.pry
          yield(envs, exec_ary)
        end
      end

      # If a source_repository is present then add the relevant attributes to the ENV hash
      def source_envs(envs)
        return {} unless options.source_repository && (source = Cnfs.repositories[options.source_repository.to_sym])

        path = Pathname.new(envs[:repo_path]).join('..', source.name).to_s
        base = { source_repo_name: source.name, source_repo_path: path }
        return base unless options.key?(:gem)

        base.merge!(gem_name: options.gem, source_gem_path: "services/#{options.gem_source}")
      end

      # Add the service attributes to the ENV hash
      # TODO: Check Cnfs.repository.test_with
      # TODO: Should require that options.type always be present?
      def service_envs
        base = options.type ? { type: options.type } : {}
        base.merge(app_dir: options.type.eql?('plugin') ? 'spec/dummy' : '.')
      end

      def base_exec
        exec_ary = options.type&.eql?('plugin') ? ['rails plugin new --full'] : ['rails new']
        # TODO: These strings should be external configuration values
        exec_ary.append('--api -G -S -J -C -T -M --skip-turbolinks --skip-active-storage')
        exec_ary.append('--dummy-path=spec/dummy') if options.type&.eql?('plugin') && options.test_with&.eql?('rspec')
        exec_ary.append('--database=postgresql')
        exec_ary
      end

      # If the project has a customized service generator then prefer that over the internal generator
      def rails_template_string(generator_name)
        relative_path = internal_path.to_s.delete_prefix("#{Cnfs::Cli::Rails.gem_root}/app/")
        user_path = Cnfs.project_root.join(Cnfs.paths.lib).join(relative_path)
        exec_path = user_path.join(generator_name).exist? ? user_path : internal_path
        "-m #{exec_path.join(generator_name)}"
      end

      # Rails::Repositories::NewGenerator
      # New rails repo; source repo is nil
      # def one
      #   { repo_name: name, repo_path: '.' }
      # end

      # New rails repo; source repo is ros
      # def two
      #   { repo_name: name, repo_path: '.', source_repo_name: 'ros', source_repo_path: '../ros' }
      # end

      # New rails service; source repo is nil
      # def three
      #   { repo_name: Cnfs.repository.name, repo_path: '../..', service_name: name }
      # end

      # New rails service; source repo is ros
      # def four
      #   { repo_name: Cnfs.repository.name, repo_path: '../..', service_name: name,
      #     source_repo_name: 'ros', source_repo_path: '../../../ros'
      #   }
      # end

      # New core service; source repo is nil
      # NOTE: Not sure; not tested
      def five
        { repo_name: Cnfs.repository.name, repo_path: '../..', service_name: name, gem_name: "cnfs-#{name}" }
      end

      # New core service; source repo is ros
      def six
        { repo_name: Cnfs.repository.name, repo_path: '../..', service_name: name, gem_name: "cnfs-#{name}",
          source_repo_name: 'ros', source_repo_path: '../../../ros'
        }
      end

      # New cnfs service; source repo is ros (or nil)
      def seven
        { repo_name: Cnfs.repository.name, repo_path: '../..', service_name: name }
      end
    end
  end
end
