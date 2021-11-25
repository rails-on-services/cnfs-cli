# frozen_string_literal: true

require 'active_model'
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
    Cnfs.with_timer('Command execution') { yield }
  end
end
