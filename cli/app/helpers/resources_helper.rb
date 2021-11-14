# frozen_string_literal: true

module ResourcesHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper

    around_execute :timer
  end

  def raise_if_runtimes_empty
    return if context.resource_provisioners.any?

    raise Cnfs::Error, "Services not found: #{context.args.resource || context.args.resources.join(' ')}"
  end

  # def before_execute
  #   raise Cnfs::Error, "No builder configured for '#{project.environment.name}' environment" unless builder
  #
  #   # project.path(to: :templates).rmtree
  #   builder.blueprint = blueprint
  #   builder.generate
  #   # builder.prepare if builder.respond_to?(:prepare)
  # end

  # def run_in_path(*commands)
  #   Dir.chdir(builder.destination_path) do
  #     commands.each do |cmd|
  #       cmd_array = builder.send(cmd)
  #       result = command.run!(*cmd_array)
  #       yield result if block_given?
  #       raise Cnfs::Error, result.err if result.failure?
  #     end
  #   end
  # end
  #
  # def builder
  #   @builder ||= blueprint.builder
  # end

  # def blueprint
  #   @blueprint ||= project.environment.blueprints.first
  # end
end
