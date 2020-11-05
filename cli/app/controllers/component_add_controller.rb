# frozen_string_literal: true
require 'rails/railtie'
require 'active_support/log_subscriber'
require 'lockbox'

class ComponentAddController < Thor
  register Component::RepositoryController, 'repository', 'repository TYPE NAME', 'add a repository of TYPE: rails, angular or url'

  class_option :force, desc: 'Do not prompt for confirmation',
    aliases: '-f', type: :boolean

  desc 'blueprint PROVIDER NAME', 'Add blueprint to environment or namespace'
  def blueprint(provider, name)
    reset_options
    run(:blueprint, provider: provider, name: name)
  end

  desc 'environment NAME', 'Add environment to project'
  def environment(name)
    run(:environment, name: name, action: :invoke)
  end

  desc 'namespace NAME', 'Add namespace to environment'
  def namespace(name)
    run(:namespace, name: name, action: :invoke)
  end

  # NOTE:
  # requires repository_type; anything like service_type is dependent upon the repository_type
  # Reads and returns the repository configuration from src/repo/cnfs.yml if it exists
  def self.read_repo_options
    empty_options = Thor::CoreExt::HashWithIndifferentAccess.new
    return empty_options unless ARGV[1].eql?('service') || ARGV[2].eql?('service')

    repo_name = Cnfs.repository_root.split.last.to_s
    # binding.pry
    # repo_name = Cnfs.config.repository
    if (repo_index = ARGV.index('-r') || ARGV.index('--repository'))
      repo_name = ARGV[repo_index + 1]
    end
    # Remove any additional cli arguments when help is invoked to prevent a Thor error
    ARGV.pop(ARGV.size - 3) if ARGV[1].eql?('help') || ARGV[1].eql?('-h')
    return empty_options unless repo_name

    path = Cnfs.paths.src.join(repo_name, '.cnfs.yml')
    return empty_options unless path.exist?

    Thor::CoreExt::HashWithIndifferentAccess.new(YAML.load_file(path))
  end

  repo_options = read_repo_options

  option :repository, desc: 'The repository in which to generate the service',
    aliases: '-r', type: :string
  option :repository_type, type: :string, default: repo_options.repository_type
  if repo_options.repository_type.eql?('rails')
    option :type, desc: 'The service type to generate, application or plugin',
      aliases: '-t', type: :string, default: repo_options.service_type || 'application'
    if repo_options.service_type.eql?('application')
      option :gem, desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
        aliases: '-g', type: :string
      option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
        aliases: '-s', type: :string
    end
  end
  desc 'service NAME', 'Add a service to a repository'
  def service(name)
    # environment and namespace need to be specified on the command line which determines which
    # services.yml file will be updated with the new service definition
    reset_options
    run(:service, name: name, action: :invoke)
  end

  private

  def run(command_name, arguments = {})
    controller_name = "component/#{command_name}_controller".camelize
    unless (controller_class = controller_name.safe_constantize)
      raise Cnfs::Error, set_color("Class not found: #{controller_name} (this is a bug. please report)", :red)
    end

    arguments = Thor::CoreExt::HashWithIndifferentAccess.new(arguments)
    controller = controller_class.new(options: options, arguments: arguments)
    method = self.class.name.downcase.delete_prefix('component').delete_suffix('controller')
    controller.send(method)
  end

  # Ensure that environment and namespace were passed on the cli and not just default values
  def reset_options
    opts = options.except('environment', 'namespace')
    if (env = ARGV.index('-e') || ARGV.index('--environment'))
      opts['environment'] = ARGV[env + 1]
    end
    if (ns = ARGV.index('-n') || ARGV.index('--namespace'))
      opts['namespace'] = ARGV[ns + 1]
    end
    @options = Thor::CoreExt::HashWithIndifferentAccess.new(opts)
  end
end
