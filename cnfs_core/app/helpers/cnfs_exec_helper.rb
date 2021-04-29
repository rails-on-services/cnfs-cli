# frozen_string_literal: true

module CnfsExecHelper
  extend ActiveSupport::Concern

  included do
    attr_accessor :options, :args
  end

  def initialize(options:, args:)
    @options = options
    @args = args
    before_execute if respond_to?(:before_execute)
  end

  def queue
    @queue ||= CommandQueue.new # (halt_on_failure: true)
  end

  def project
    Cnfs.project
  end

  # Shortcut for CRUD controller's create and update methods
  # Ex: crud_with(Build.new(project: Cnfs.project))
  def crud_with(obj, location = 1)
    method = caller_locations(1, location)[location - 1].label
    obj.view.send(method)
    return obj if obj.save

    $stdout.puts obj.errors.map(&:full_message).join("\n")
  end
end
