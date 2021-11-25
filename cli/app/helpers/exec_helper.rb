# frozen_string_literal: true

module ExecHelper
  extend ActiveSupport::Concern
  include CnfsExecHelper

  included do
    extend CnfsExecHelper

    attr_accessor :context

    define_model_callbacks :execute
  end

  # TODO: When moving queue to cnfs_core then move this
  def queue
    @queue ||= CommandQueue.new # (halt_on_failure: true)
  end

  # Shortcut for CRUD controller's create and update methods
  # Ex: crud_with(Build.new(project: Cnfs.project))
  def crud_with(obj, location = 1)
    method = caller_locations(1, location)[location - 1].label
    obj.view.send(method)
    return obj if obj.save

    $stdout.puts obj.errors.map(&:full_message).join("\n")
  end

  def init
    return unless context.options.init

    CnfsCli.asset_names.each do |asset|
      klass = asset.classify.constantize
      klass.init(context) if klass.respond_to?(:init)
    end
  end
end
