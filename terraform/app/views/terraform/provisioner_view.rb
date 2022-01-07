# frozen_string_literal: true

class Terraform::ProvisionerView < ApplicationView
  def modify
    model.set_defaults
    ask_attr(:state_file)
  end
end
