# frozen_string_literal: true

class ImagesController < Thor
  include CommandHelper

  class_option :generate, desc: 'Force generate manifest files ',
                          aliases: '-g', type: :string

  cnfs_class_options :dry_run, :quiet, :clean
  cnfs_class_options CnfsCli.config.segments.keys

  desc 'build [IMAGES]', 'Build all or specific service images'
  def build(*services)
    execute(services: services, controller: :build, method: :build)
  end

  desc 'list', 'Lists services configured in the project'
  def list
    puts context.images.pluck(:name).join("\n")
  end

  desc 'push [IMAGES]', 'Push images to designated repository'
  def push(*services)
    execute(services: services, controller: :build, method: :push)
  end

  desc 'pull [IMAGES]', 'Pull one or more or all images'
  def pull(*services)
    execute(services: services, controller: :build, method: :pull)
  end

  desc 'test [IMAGES]', 'Run test commands on service image(s)'
  option :build,      desc: 'Build image before testing',
                      aliases: '-b', type: :boolean
  option :fail_all,   desc: 'Skip any remaining services after a test fails',
                      aliases: '--fa', type: :boolean
  option :fail_fast,  desc: 'Skip any remaining tests for a service after a test fails',
                      aliases: '--ff', type: :boolean
  option :push,       desc: 'Push image after successful testing',
                      aliases: '-p', type: :boolean
  def test(*services)
    execute(services: services, controller: :build, method: :test)
  end
end
