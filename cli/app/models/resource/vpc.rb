# frozen_string_literal: true

class Resource::Vpc < Resource
  store :config, accessors: %i[name cidr create_elasticache_subnet_group create_database_subnet_group], coder: YAML

  def cidr; super || '10.0.0.0/16' end
  def create_database_subnet_group; super || false end
  def create_elasticache_subnet_group; super || false end
end
