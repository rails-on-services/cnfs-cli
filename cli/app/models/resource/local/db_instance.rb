# frozen_string_literal: true

# This represents Postgres on the local machine
class Resource::Local::DbInstance < Resource
  def shell
    system('psql')
  end
end
