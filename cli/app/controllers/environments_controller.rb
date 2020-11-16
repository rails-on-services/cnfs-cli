# frozen_string_literal: true

class EnvironmentsController < CommandsController
  OPTS = %i[noop quiet verbose].freeze
  include Cnfs::Options

  map %w[i] => :infra
  register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Manage environment infrastructure. (short-cut: i)'

  desc 'add NAME', 'Add environment to project'
  def add(name)
    Environments::AddRemoveController.new(options: options, arguments: { name: name }).execute(:invoke)
  end

  desc 'list', 'List configured environments'
  def list
    puts Cnfs.paths.config.join('environments').children.select(&:directory?).sort.map { |path| path.split.last }
  end

  desc 'remove NAME', 'Remove environment from project'
  def remove(name)
    Environments::AddRemoveController.new(options: options, arguments: { name: name }).execute(:revoke)
  end

  # NOTE: It may be that run command will not understand the namespace of the Infra commands
  desc 'init', 'Initialize the environment'
  long_desc <<-DESC.gsub("\n", "\x5")

  Initializes the environment's infrastructure, e.g. authenticate to a K8s cluster, e.g. EKS

  DESC
  option :environment, desc: 'Target environment',
                       aliases: '-e', type: :string, default: Cnfs.config.environment
  # TODO: Only include aws options if the environment is AWS
  option :long, desc: 'Run the long form of the command',
                aliases: '-l', type: :boolean
  option :role_name, desc: 'Override the AWS IAM role to be used',
                     aliases: '-r', type: :string
  def init
    run(:init)
  end
end
