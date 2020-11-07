# frozen_string_literal: true

class ImagesController < CommandsController
  OPTS = %i[env ns noop quiet verbose]
  include Cnfs::Options

  desc 'build [IMAGES]', 'Build all or specific service images'
  # NOTE: build and connect is really only valid for local otherwise need to deploy first
  option :shell, desc: 'Connect to service shell after building',
    aliases: '--sh', type: :boolean
  # TODO: Take an environment for which to build; target is just infra like a k8s cluster
  # application is just the colleciton of services; namespace is where it's deployed
  # so namespace would declare the environment, e.g. production, etc
  # def build(namespace_name, *service_names)
  # TODO: Things like the image naming convention should be part of the service.config with a store accessor
  # so that each image and within an environment/namespace _could_ have its own naming pattern
  # option :all,
  #   aliases: '-a', type: :boolean
  def build(*services)
    run(:build, services: services, service: services.last)
  end

  desc 'test [IMAGES]', 'Run test commands on service image(s)'
  option :build, desc: 'Build image before testing',
    aliases: '-b', type: :boolean
  option :fail_all, desc: 'Skip any remaining services after a test fails',
    aliases: '--fa', type: :boolean
  option :fail_fast, desc: 'Skip any remaining tests for a service after a test fails',
    aliases: '--ff', type: :boolean
  option :push, desc: 'Push image after successful testing',
    aliases: '-p', type: :boolean
  # TODO: How to handle service names?
  def test(*args)
    run(:test, args)
  end

  desc 'push [IMAGES]', 'Push one or more images'
  def push(*services)
    run(:push, services: services)
  end

  desc 'pull [IMAGES]', 'Pull one or all images'
  def pull(*services)
    run(:pull, services: services)
  end
end
