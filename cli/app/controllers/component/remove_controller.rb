# frozen_string_literal: true

module Component
  class RemoveController < ComponentController
    desc 'blueprint PROVIDER NAME', 'Remove blueprint from environment or namespace'
    def blueprint(provider, name)
      run(:blueprint, provider: provider, name: name, action: :revoke)
    end

    desc 'environment NAME', 'Remove environment from project'
    def environment(name)
      return unless (options.force || yes?('Are you sure?'))

      run(:environment, name: name, action: :revoke)
    end

    desc 'namespace NAME', 'Remove namespace from environment'
    def namespace(name)
      return unless (options.force || yes?('Are you sure?'))

      run(:namespace, name: name, action: :revoke)
    end

    desc 'repository NAME', 'Remove a repository from the project'
    def repository(name)
      return unless (options.force || yes?("\n#{'WARNING!!!  ' * 5}\nThis will destroy the repository.\nAre you sure?"))

      Cnfs.require_deps
      Cnfs.require_project!(arguments: {}, options: options, response: nil)
      raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

      repo.delete
    end

    desc 'service NAME', 'Remove a service from the repository'
    option :type, desc: 'The service type to generate',
      aliases: '-t', type: :string # , required: :true
    def service(name)
      return unless (options.force || yes?('Are you sure?'))

      run(:service, name: name, action: :revoke)
    end

    private

    def action
      :remove
    end
  end
end
