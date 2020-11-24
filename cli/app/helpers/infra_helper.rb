# frozen_string_literal: true

module InfraHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper
    include TtyHelper
  end

  def before_execute
    raise Cnfs::Error, "No builder configured for '#{project.environment.name}' environment" unless builder

    builder.generate
  end

  def builder
    project.environment.builder
  end
end
