# frozen_string_literal: true

# This represents Redis on the local machine
class Resource::Local::CacheInstance < Resource
  def shell
    system('redis-cli')
  end
end
