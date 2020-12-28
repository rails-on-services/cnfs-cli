# frozen_string_literal: true

class Blueprint::View < ApplicationView
  def select_provider
    provider_names = Provider.where(type: 'Provider::Local').pluck(:name)
    return unless provider_names.any?

    provider_name = enum_select('Provider:', provider_names)
    model.provider = Provider.find_by(name: provider_name)
  end

  def select_builder
    builders = model.class.builder_types
    builder =
      if builders.size.eql?(1)
        ok("Builder: #{builders.first}")
        builders.first
      else
        enum_select('Builder:', builders)
      end
    "builder/#{builder}".classify.safe_constantize.first
  end
end
