# frozen_string_literal: true

module OneStack
  class ProvisionerView < ApplicationView
    def modify
      %i[name].each { |attr| ask_attr(attr) } if action.eql?(:edit) || model.name.nil?
      select_type
    end
  end
end
