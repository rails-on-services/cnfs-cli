# frozen_string_literal: true

module EnvironmentsHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper
    include TtyHelper
  end
end
