# frozen_string_literal: true

module ExecHelper
  extend ActiveSupport::Concern

  included do
    attr_accessor :options, :args
  end

  def initialize(options:, args:)
    @options = options
    @args = args
    before_execute if respond_to?(:before_execute)
  end

  def project
    Cnfs.project
  end
end
