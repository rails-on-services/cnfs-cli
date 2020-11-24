# frozen_string_literal: true

module ExecHelper
  extend ActiveSupport::Concern

  included do
    attr_accessor :options, :args
  end

  def initialize(options:, args:)
    @options = options
    @args = args
    # project.process_manifests if command_set_requires_manifests?
    before_execute if respond_to?(:before_execute)
  end

  # def command_set_requires_manifests?
  #   %w[namespaces services images].include?(self.class.module_parent.to_s.underscore)
  # end

  def project
    Cnfs.project
  end
end
