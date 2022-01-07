# frozen_string_literal: true

module Images
  class CommandController < Thor
    include Concerns::CommandController

    cnfs_class_options :clean, :dry_run, :generate, :quiet
    cnfs_class_options Cnfs.config.segments.keys

    desc 'build [IMAGES]', 'Build all or specific service images'
    def build(*images) = execute(images: images)

    desc 'pull [IMAGES]', 'Pull one or more or all images'
    def pull(*images) = execute(images: images)

    desc 'push [IMAGES]', 'Push images to designated repository'
    def push(*images) = execute(images: images)

    desc 'test [IMAGES]', 'Run test commands on service image(s)'
    option :build,      desc: 'Build image before testing',
                        aliases: '-b', type: :boolean
    option :fail_all,   desc: 'Skip any remaining services after a test fails',
                        aliases: '--fa', type: :boolean
    option :fail_fast,  desc: 'Skip any remaining tests for a service after a test fails',
                        aliases: '--ff', type: :boolean
    option :push,       desc: 'Push image after successful testing',
                        aliases: '-p', type: :boolean
    def test(*images) = execute(images: images)
  end
end
