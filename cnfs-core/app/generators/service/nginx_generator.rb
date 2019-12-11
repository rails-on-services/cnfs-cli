# frozen_string_literal: true

class Service::NginxGenerator < ServiceGenerator

  def manifest
    template("service/nginx/#{orchestrator}.yml.erb", "#{write_path}/#{service.name}.yml")
  end

  def nginx_conf
    template('service/nginx/nginx.conf.erb', "#{write_path}/nginx.conf")
  end

  private

  # TODO: this assumes 'target' but it could be application
  def volume
    "../../target/#{layer.name}/nginx.conf:/etc/nginx/conf.d/default.conf"
  end

  def nginx_services
    application.services.select{|s| s.profiles.include? 'server' if s.respond_to?(:profiles) }.map(&:name)
  end
end
