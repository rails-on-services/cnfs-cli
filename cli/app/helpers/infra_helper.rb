# frozen_string_literal: true

module InfraHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper
    include TtyHelper
  end

  def before_execute
    raise Cnfs::Error, "No builder configured for '#{project.environment.name}' environment" unless builder

    # project.path(to: :templates).rmtree
    builder.generate
    builder.prepare if builder.respond_to?(:prepare)
  end

  def run_in_path(cmd)
    Dir.chdir(project.path(to: :templates)) do
      cmd_array = project.environment.builder.send(cmd)
      result = command.run!(*cmd_array)
      yield result if block_given?
      raise Cnfs::Error, result.err if result.failure?
    end
  end

  def builder
    project.environment.builder
  end
end
