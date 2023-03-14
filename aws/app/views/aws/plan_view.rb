# frozen_string_literal: true

class Aws::PlanView < OneStack::ApplicationView
  def create
    # model.name = ask('Blueprint name:', value: random_string('instance'))
    # binding.pry
    p_ask(:name)
    provider_name = enum_select('Provider:', OneStack::Provider.where(type: 'Provider::Aws').pluck(:name))
    model.provider = OneStack::Provider.find_by(name: provider_name)
    # TODO: These two will become configurable
    model.builder = OneStack::Builder.find_by(name: 'terraform')
    model.runtime = OneStack::Runtime.find_by(name: 'compose')
  end
end
