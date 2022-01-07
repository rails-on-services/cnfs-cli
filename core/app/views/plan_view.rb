# frozen_string_literal: true

class PlanView < ApplicationView
  def modify
    binding.pry
=begin
    %i[name].each { |attr| ask_attr(attr) } if action.eql?(:edit) || model.name.nil?
    select_type
    enum_select_attr(:provider_name, choices: provider_names)
    enum_select_attr(:provisioner_name, choices: provisioner_names)
    yes_attr(:abstract, default: false)
    yes_attr(:inherit, default: true)
    yes_attr(:enable, default: true)
=end

    # return if choices.size.zero?
    # return choices.first if choices.size.eql?(1)
  end
end
