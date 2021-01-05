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
end
