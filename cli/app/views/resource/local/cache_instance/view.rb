# frozen_string_literal: true

class Resource::Local::CacheInstance::View < ResourceView
  def edit
    model.name = ask('Name:', value: random_string('cache-instance'))
  end
end
