# frozen_string_literal: true

module OneStack
  class RepositoryView < ApplicationView
    def modify
      %i[name].each { |attr| ask_attr(attr) } if action.eql?(:edit) || model.name.nil?
      select_type
      ask_attr(:url)
    end
  end
end
