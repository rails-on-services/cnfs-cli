# frozen_string_literal: true

module Component
  class RemoveController < ComponentController
    option :environment, desc: 'Target environment',
      aliases: '-e', type: :string, default: Cnfs.config.environment
    option :namespace, desc: 'Target namespace',
      aliases: '-n', type: :string
    desc 'blueprint PROVIDER NAME', 'Remove blueprint from environment or namespace'
    def blueprint(provider, name)
      run(:blueprint, provider: provider, name: name) # , action: :revoke)
    end

    desc 'environment NAME', 'Remove environment from project'
    def environment(name)
      return unless (options.force || yes?('Are you sure?'))

      run(:environment, name: name) # , action: :revoke)
    end

    desc 'namespace NAME', 'Remove namespace from environment'
    option :environment, desc: 'Target environment',
      aliases: '-e', type: :string, default: Cnfs.config.environment
    def namespace(name)
      return unless (options.force || yes?('Are you sure?'))

      run(:namespace, name: name) #  , action: :revoke)
    end

    desc 'repository NAME', 'Remove a repository from the project'
    def repository(name)
      return unless (options.force || yes?("\n#{'WARNING!!!  ' * 5}\nThis will destroy the repository.\nAre you sure?"))

      Cnfs.require_deps
      Cnfs.require_project!(arguments: {}, options: options, response: nil)
      raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

      repo.delete
    end

    desc 'service NAME', 'Remove a service from the project'
    option :environment, desc: 'Target environment',
      aliases: '-e', type: :string
    option :namespace, desc: 'Target namespace',
      aliases: '-n', type: :string
    option :repository, desc: 'Remove the service from a repository',
      aliases: '-r', type: :string
    def service(name)
      return unless (options.force || yes?("\n#{'WARNING!!!  ' * 5}\nThis will destroy the service.\nAre you sure?"))

      cs = controller_class(:service).new
      cs.action = :revoke
      cs.send(name)
      # run(:service, name: name)
    end

    private

    def action
      :revoke
    end
  end
end
