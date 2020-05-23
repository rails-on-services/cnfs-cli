# frozen_string_literal: true

class TargetNamespace < ApplicationRecord
  belongs_to :target
  belongs_to :namespace
end
