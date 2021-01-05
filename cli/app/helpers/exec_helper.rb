# frozen_string_literal: true

module ExecHelper
  extend ActiveSupport::Concern
  include CnfsExecHelper

  included do
    extend CnfsExecHelper
  end

  def each_runtime
    environment.runtimes.each do |runtime|
      runtime.queue = queue
      # TODO: See if update works; it writes a bunch of stuff to config/project.yml
      # If it requires reload then that is pretty useless
      # project.update(runtime: runtime)
      project.runtime = runtime
      # Prepare should be handled by the CommandController
      # project.runtime.prepare
      # binding.pry
      runtime_services = respond_to?(:services) ? services.where(type: runtime.supported_service_types) : []
      yield runtime, runtime_services
    end
  end

  def environment
    project.environment
  end
end
