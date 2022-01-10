# frozen_string_literal: true

class ProviderView < ApplicationView
  include Concerns::AssetView

  def modify
    %i[name].each { |attr| ask_attr(attr) } if action.eql?(:edit) || model.name.nil?
    # select_type
  end
end
