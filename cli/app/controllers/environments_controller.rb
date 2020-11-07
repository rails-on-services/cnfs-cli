# frozen_string_literal: true

class EnvironmentsController < CommandsController
  OPTS = %i[env noop quiet verbose]
  include Cnfs::Options

  map %w[i] => :infra
  register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Manage environment infrastructure'

  # NOTE: It may be that run command will not understand the namespace of the Infra commands
  desc 'init', 'Initialize the cluster'
  option :long, desc: 'Run the long form of the command',
    aliases: '-l', type: :boolean
  option :role_name, desc: 'Override the aws iam role to be used',
    aliases: '-r', type: :string
  def init
    run(:init)
  end
end
