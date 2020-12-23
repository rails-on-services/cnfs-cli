# frozen_string_literal: true

require 'cnfs/cli/aws/version'

module Cnfs
  module Cli
    module Aws
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          Cnfs.logger.info "[Aws] Initializing from #{gem_root}"
        end

        def on_project_initialize; end

        def add_console_shortcuts(options)
          Cnfs.logger.info '[Aws] Adding console shortcuts'
          shortcuts = options.shift
          shortcuts.merge!({
            acm: Resource::Aws::ACM.new(provider: Provider::Aws.first).client,
            ec2: Resource::Aws::EC2.new(provider: Provider::Aws.first).client,
            eks: Resource::Aws::EKS.new(provider: Provider::Aws.first).client,
            rds: Resource::Aws::RDS.new(provider: Provider::Aws.first).client,
            vpc: Resource::Aws::Vpc.new(provider: Provider::Aws.first).client,
          })
        end

        def before_loader_setup(options)
          Cnfs.logger.info '[Aws] Configuring loader'
          loader = options.shift

          loader.inflector.inflect(
            'acm' => 'ACM',
            'ec2' => 'EC2',
            'eks' => 'EKS',
            'rds' => 'RDS',
          )
        end

        # TODO: Copy in blueprints, etc
        def customize; end
      end
    end
  end
end
