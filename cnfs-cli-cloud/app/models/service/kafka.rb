# frozen_string_literal: true

class Service::Kafka < Service
  store :config, accessors: %i[security_protocol sasl_mechanism username password configuration_overrides], coder: YAML
  store :config, accessors: %i[bootstrap_servers ui], coder: YAML

  def configuration_overrides
    super || {}
  end

  def namespace_name
    '{namespace}'.cnfs_sub
  end
end
