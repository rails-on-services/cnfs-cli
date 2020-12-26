# frozen_string_literal: true

# This represents Docker on the local machine
class Resource::Local::Instance < Resource
  def shell
    system('bash')
  end
end
