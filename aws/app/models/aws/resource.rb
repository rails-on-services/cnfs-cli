# frozen_string_literal: true

class Aws::Resource < Resource

  def client
    @client ||= self.class.client(provider)
  end

  class << self
    def client(provider)
      require "aws-sdk-#{service_name}"
      klass = "Aws::#{service_class_name}::Client".safe_constantize
      raise Cnfs::Error, "AWS SDK client class not found for: #{service_name}" unless klass

      config = client_config(provider)
      klass.new(config)
    rescue LoadError => e
      raise Cnfs::Error, "AWS SDK not found for: #{service_name}"
    end

    def client_config(provider)
      provider.client_config(service_name)
    end

    def service_name
      service_class_name.underscore
    end

    def service_class_name
      name.split('::')[2]
    end
  end
end
