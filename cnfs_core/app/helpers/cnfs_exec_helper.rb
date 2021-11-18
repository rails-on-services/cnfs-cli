# frozen_string_literal: true

module CnfsExecHelper
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Callbacks
    include ActiveModel::AttributeAssignment

    attr_accessor :options, :args
  end

  def initialize(**kwargs)
    assign_attributes(**kwargs)
  end

  # Implement with an around_execute :timer call in the controller
  def timer
    start_time = Time.now
    yield
    title = 'command execution'
    Cnfs.timers[title] = Time.now - start_time
    Cnfs.logger.debug("Completed #{title} in #{Time.now - start_time} seconds")
  end
end
