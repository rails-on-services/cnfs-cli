# frozen_string_literal: true

class BlueprintsController < Thor
  OPTS = %i[env force noop quiet verbose]
  include Cnfs::Options

  desc 'add PROVIDER NAME', 'Add blueprint to environment or namespace'
  option :namespace, desc: 'Target namespace',
    aliases: '-n', type: :string
  def add(provider, name)
    Blueprints::AddRemoveController.new(options: options, arguments: { provider: provider, name: name }).execute(:invoke)
  end
end
