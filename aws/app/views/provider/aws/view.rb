# frozen_string_literal: true

class Provider::Aws::View < ApplicationView
  def edit
    model.region = enum_select('Region:', model.regions, per_page: model.regions.size)
  end
end
