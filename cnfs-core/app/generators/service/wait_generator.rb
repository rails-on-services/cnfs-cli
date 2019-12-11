# frozen_string_literal: true

class Service::WaitGenerator < ServiceGenerator
  def manifest
    template("service/wait/#{orchestrator}.yml.erb", "#{write_path}/#{service.name}.yml")
  end

  private

  def depends_on
    configured_services.map { |key| "- #{key}" }.join("\n      ")
  end

  def targets
    configured_services.map { |key| "#{key}:#{dependency_ports[key.to_sym]}" }.join(',')
  end

  def configured_services
    dependency_ports.stringify_keys.keys & target.services.pluck(:name)
  end

  def dependency_ports
    {
      postgres: '5432',
      redis: '6379',
      fluentd: '24224',
      localstack: '4572'
    }
  end
end
