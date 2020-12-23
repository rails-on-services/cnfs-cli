# frozen_string_literal: true
# See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/RDS/Client.html

class Resource::Aws::RDS < Resource::Aws
  store :config, accessors: %i[db_instance_class], coder: YAML
end
