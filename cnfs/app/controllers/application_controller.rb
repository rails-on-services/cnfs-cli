# frozen_string_literal: true

# deployment has many targets
# each target has a runtime
# deployment has one application
# application has many layers
# each layer has many services

# args, options

class ApplicationController < Thor

  private

  def run(command_name, args)
    if options[:help]
      invoke(:help, [command_name.to_s])
      return
    end
    # deployment_name = options.deployment || ENV['CNFS_DEPLOY'] || args.shift || :default
    deployment_name = options.deployment || ENV['CNFS_DEPLOY'] || :default
    unless (deployment = Deployment.find_by(name: deployment_name))
      STDOUT.puts "Deployment not found: #{deployment_name}"
      return
    end
    command_string = "#{self.class.name.gsub('Controller', '')}::#{command_name.to_s.camelize}Controller"
    unless (command = command_string.safe_constantize)
      STDOUT.puts "Command not found: #{command_name}"
      return
    end
    command.new(deployment, args, options).call
  end
end
