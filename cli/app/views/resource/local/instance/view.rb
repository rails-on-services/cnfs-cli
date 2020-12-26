# frozen_string_literal: true

class Resource::Local::Instance::View < ResourceView
  def edit
    model.name = ask('Name:', value: random_string('instance'))
  end
end
