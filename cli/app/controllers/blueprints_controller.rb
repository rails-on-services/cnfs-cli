# frozen_string_literal: true

class BlueprintsController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :environment, :dry_run, :logging
  # class_option :namespace, desc: 'Target namespace',
  #                          aliases: '-n', type: :string

  desc 'add NAME', 'Add environment to project'
  before :initialize_project
  before :ensure_valid_project
  def add # (name)
    # execute({ name: name }, :crud, 2, :add)
    execute({}, :crud, 2, :add)
  end

  # register Blueprints::AddController, 'add', 'add SUBCOMMAND [options]', 'Create a new blueprint in the specified environment or namespace'
  # desc 'add PROVIDER NAME', 'Add a blueprint to the environment or namespace'

  # desc 'remove PROVIDER NAME', 'Remove a blueprint from the environment or namespace'
  # def remove(provider, name)
  #   Blueprints::AddRemoveController.new(options: options.merge(behavior: :revoke), arguments: { provider: provider, name: name }).execute
  # end
end
