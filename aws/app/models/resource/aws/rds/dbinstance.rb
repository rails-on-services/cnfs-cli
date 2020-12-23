# frozen_string_literal: true

class Resource::Aws::RDS::DBInstance < Resource::Aws::RDS
  store :config, accessors: %i[db_instance_class], coder: YAML
end
