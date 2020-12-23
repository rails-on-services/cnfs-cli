# frozen_string_literal: true

class Resource::Aws < Resource
  attr_accessor :provider

  def client
    service = service_name.underscore
    require "aws-sdk-#{service}"
    klass = "Aws::#{service_name}::Client".safe_constantize
    raise Cnfs::Error, "AWS SDK client class not found for: #{service}" unless klass

    klass.new(client_config)
  rescue LoadError => e
    raise Cnfs::Error, "AWS SDK not found for: #{service}"
  end

  def client_config
    provider.client_config(service_name.underscore)
  end
end
