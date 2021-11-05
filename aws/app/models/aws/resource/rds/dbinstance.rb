# frozen_string_literal: true

class Aws::Resource::RDS::DBInstance < Aws::Resource::RDS
  store :config, accessors: %i[db_instance_class], coder: YAML
end
