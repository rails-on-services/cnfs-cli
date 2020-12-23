# frozen_string_literal: true

class EnvironmentsController < Thor
  include CommandHelper

  # map %w[i] => :infra
  # register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Manage environment infrastructure. (short-cut: i)'
  class_before :initialize_project
  class_before :ensure_valid_project

  no_commands do
    def create(name)
      execute({ name: name }, :crud, 2, :create)
    end
  end

  desc 'create NAME', 'Add environment to project'
  def create
    execute({}, :crud, 2, :create)
  end

  # desc 'init', 'Initialize the environment'
  # long_desc <<-DESC.gsub("\n", "\x5")

  # Initializes the environment's infrastructure, e.g. authenticate to a K8s cluster, e.g. EKS

  # DESC
  # option :environment, desc: 'Target environment',
  #                      aliases: '-e', type: :string, default: Cnfs.config.environment
  # # TODO: Only include aws options if the environment is AWS
  # option :long,        desc: 'Run the long form of the command',
  #                      aliases: '-l', type: :boolean
  # option :role_name,   desc: 'Override the AWS IAM role to be used',
  #                      aliases: '-r', type: :string
  # def init
  #   execute
  # end

  desc 'list', 'List configured environments'
  def list
    execute({}, :crud, 2, :list)
  end

  desc 'remove NAME', 'Remove environment from project'
  def remove(name)
    execute({ name: name, behavior: :revoke }, :crud, 2, :destroy)
  end

  desc 'update NAME', 'Add environment to project'
  def update(name)
    execute({ name: name }, :crud, 2, :update)
  end

  private

  def x_infra
    Pry.start(InfraController.new(args || [], options))
  end
end
