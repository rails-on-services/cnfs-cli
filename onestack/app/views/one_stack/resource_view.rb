# frozen_string_literal: true

module OneStack
  class ResourceView < ApplicationView
    def modify
      %i[name].each { |attr| ask_attr(attr) } if action.eql?(:edit) || model.name.nil?
    end
  end
end
