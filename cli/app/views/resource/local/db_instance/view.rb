# frozen_string_literal: true

class Resource::Local::DbInstance::View < ResourceView
  def edit
    model.name = ask('Name:', value: random_string('db-instance'))
  end
end
