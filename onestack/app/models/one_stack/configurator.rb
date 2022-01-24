# frozen_string_literal: true

module OneStack
  class Configurator < ApplicationRecord
    include OneStack::Concerns::Operator

    attr_accessor :playbooks

    before_execute :generate

    def target() = :playbooks
  end
end
