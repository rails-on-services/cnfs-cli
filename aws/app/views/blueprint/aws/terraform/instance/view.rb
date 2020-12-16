# frozen_string_literal: true

class Blueprint::Aws::Terraform::Instance::View < BaseView
  # attr_accessor :model

  def render(model)
    model.name = ask('Blueprint name:', value: "instance-#{random_string}")
    provider_name = enum_select('Provider:', Provider.where(type: 'Provider::Aws').pluck(:name))
    model.provider = Provider.find_by(name: provider_name)
    model.runtime = Runtime.find_by(name: 'compose')
  end
end

