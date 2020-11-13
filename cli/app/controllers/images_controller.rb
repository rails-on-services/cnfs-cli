# frozen_string_literal: true

class ImagesController < CommandsController
  OPTS = %i[env ns noop quiet verbose]
  include Cnfs::Options

  desc 'pull [IMAGES]', 'Pull one or more or all images'
  def pull(*services)
    run(:pull, services: services)
  end

  desc 'build [IMAGES]', 'Build all or specific service images'
  # NOTE: build and connect is really only valid for local otherwise need to deploy first
  option :shell, desc: 'Connect to service shell after building',
    aliases: '--sh', type: :boolean
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
  # TODO: Test arguments are defined in the services.yml:
  # test_commands:
  #   this: bundle exec rspec ...
  #   that: bundle exec blah ...
  def test(test_command, *services)
    run(:test, command: test_command, services: services)
  end

  desc 'push [IMAGES]', 'Push images to designated repository'
  def push(*services)
    run(:push, services: services)
  end
end
