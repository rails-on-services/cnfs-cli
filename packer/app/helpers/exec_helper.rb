# frozen_string_literal: true

module ExecHelper
  extend ActiveSupport::Concern
  include CnfsExecHelper

  included do
    extend CnfsExecHelper
  end
end
