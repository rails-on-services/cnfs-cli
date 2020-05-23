# frozen_string_literal: true

class BackendController < CommandsController
  namespace :backend

  class_option :verbose, type: :boolean, default: false, aliases: '-v'
  class_option :debug, type: :numeric, aliases: '-d'
  class_option :noop, type: :boolean, aliases: '--noop'
  class_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'

  desc 'new [NAME]', 'Generate a new cnfs rails project'
  def new(project_name)
    run(:new, project_name: project_name)
  end

  desc 'generate [TYPE] [NAME]', 'Generate a rails service'
  def generate(type, service_name)
    run(:generate, type: type, service_name: service_name)
  end

  # desc 'exec SERVICE COMMAND', 'Execute a rails command on a service'
  # def exec(service, cmd)
  #   PrimaryController.new.exec(service, "rails #{cmd}")
  # end
end
