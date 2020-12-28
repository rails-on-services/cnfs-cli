# frozen_string_literal: true

class Blueprint::Aws::Instance::View < ApplicationView
  def edit
    model.name = ask('Blueprint name:', value: random_string('instance')
    provider_name = enum_select('Provider:', Provider.where(type: 'Provider::Aws').pluck(:name))
    model.provider = Provider.find_by(name: provider_name)
    # TODO: These two will become configurable
    model.builder = Builder.find_by(name: 'terraform')
    model.runtime = Runtime.find_by(name: 'compose')
  end
end

