# frozen_string_literal: true

class Resource::Aws < Resource
  attr_accessor :provider

  def ec2_client(region: 'us-east-1')
    require 'aws-sdk-ec2'
    Aws::EC2::Client.new(region: region)
  end

  def client
    require "aws-sdk-#{resource_name.underscore}"
    config = provider.client_config(resource_name.underscore)
    "Aws::#{resource_name}::Client".constantize.new(config)
  end

  # TODO: This should be removed b/c all UI takes place in the controllers
  def prompt
    TTY::Prompt.new
  end
end
