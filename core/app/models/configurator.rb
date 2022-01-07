# frozen_string_literal: true

class Configurator < ApplicationRecord
  include Concerns::Operator

  attr_accessor :playbooks

  before_execute :generate

  def target() = :playbooks
end
