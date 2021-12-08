# frozen_string_literal: true

class Configurator < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  # This Operator manages target_type
  def target_type() = :playbooks
end
