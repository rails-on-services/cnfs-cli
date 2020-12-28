# frozen_string_literal: true

class Blueprint::Local::Vagrant::View < Blueprint::View
  def edit
    model.builder = select_builder
    model.provider = select_provider
    model.name = ask('Blueprint name:', value: random_string('vagrant'))
    # model.runtime = Runtime.find_by(name: 'compose')
  end
end
