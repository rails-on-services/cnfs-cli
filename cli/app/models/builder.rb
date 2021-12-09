# frozen_string_literal: true

class Builder < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  attr_accessor :images

  before_execute :generate

  def target() = :images

  def self.commands() = %i[build push pull test]
end
