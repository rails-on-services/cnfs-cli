# frozen_string_literal: true
require 'rails/railtie'
require 'active_support/log_subscriber'
require 'lockbox'

class ComponentController < Thor
  OPTS = %i[force noop quiet verbose]
  include Cnfs::Options

  register Component::RepositoryController, 'repository', 'repository TYPE NAME', 'Add a repository of TYPE: rails, angular or url'
  register Component::ServiceController, 'service', 'service TYPE NAME', 'Add a service to the project'

  desc 'blueprint PROVIDER NAME', 'Add blueprint to environment or namespace'
  option :environment, desc: 'Target environment',
    aliases: '-e', type: :string, default: Cnfs.config.environment
  option :namespace, desc: 'Target namespace',
    aliases: '-n', type: :string
  def blueprint(provider, name)
    run(:blueprint, provider: provider, name: name, action: :invoke)
  end

  desc 'environment NAME', 'Add environment to project'
  def environment(name)
    run(:environment, name: name, action: :invoke)
  end

  desc 'namespace NAME', 'Add namespace to environment'
  option :environment, desc: 'Target environment',
    aliases: '-e', type: :string, default: Cnfs.config.environment
  def namespace(name)
    run(:namespace, name: name, action: :invoke)
  end

  private

  def run(command_name, arguments = {})
    controller_name = "component/#{command_name}_controller".camelize
    unless (controller_class = controller_name.safe_constantize)
      raise Cnfs::Error, set_color("Class not found: #{controller_name} (this is a bug. please report)", :red)
    end

    arguments = Thor::CoreExt::HashWithIndifferentAccess.new(arguments)
    controller = controller_class.new(options: options, arguments: arguments)
    method = self.class.name.demodulize.downcase.delete_prefix('component').delete_suffix('controller')
    method = arguments.action.eql?(:invoke) ? :add : :remove
    controller.send(method)
  end
end
