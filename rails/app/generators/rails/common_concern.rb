# frozen_string_literal: true

# Creates a new service in a CNFS Rails repository
module Rails
  module CommonConcern
    extend ActiveSupport::Concern

    included do
      private
      def with_context(gem_template, gem_name, path)
        env = base_env(path).merge(gem_env(path)).transform_keys!{ |key| "cnfs_#{key}".upcase }
        exec_ary = base_exec.append(rails_template_string(gem_template), gem_name)
        if options.debug
          puts env
          puts exec_ary.join(' ')
        end
        binding.pry
        inside(path) do
          yield(env, exec_ary)
        end
      end

      def base_env(path)
        {
          # code_type: 'service',
          # repository_path: '../../..',
          service_repo: options.repository, # Cnfs.repository_root.split.last.to_s,
          service_name: name,
          service_path: "#{options.repository}/#{path}/#{name}",
          service_type: options.type # plugin ? 'plugin' : 'application',
          # service_app_dir: options.type.eql?('plugin') ? 'spec/dummy/' : '.'
        }
      end

      def gem_env(path)
        return {} unless options.gem_source

        gem_repo, gem_name = options.gem_source.to_s.split('/')
        gem_name ||= name

        {
          gem_repo: gem_repo,
          gem_name: gem_name,
          gem_path: "#{gem_repo}/#{path}/#{gem_name}"
        }
      end

      def base_exec
        exec_ary = options.type&.eql?('plugin') ? ['rails plugin new --full'] : ['rails new']
        # TODO: These strings should be external configuration values
        exec_ary.append('--api -G -S -J -C -T -M --skip-turbolinks --skip-active-storage')
        exec_ary.append('--dummy-path=spec/dummy') if options.test_with.eql?('rspec')
        exec_ary.append('--database=postgresql')
        exec_ary
      end

      # If the project has a customized service generator then prefer that over the internal generator
      def rails_template_string(generator_name)
        relative_path = internal_path.to_s.delete_prefix("#{Cnfs::Cli::Rails.gem_root}/app/")
        user_path = Cnfs.project_root.join(Cnfs.paths.lib).join(relative_path)
        exec_path = user_path.join(generator_name).exist? ? user_path : internal_path
        exec_path.join(generator_name)
        "-m #{exec_path}"
      end
    end
  end
end
