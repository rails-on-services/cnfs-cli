# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Aws
      class << self
        def initialize_aws
          require 'cnfs_cli/aws'
          Cnfs.logger.info "[Aws] Initializing from #{gem_root}"
          ActiveSupport::Notifications.subscribe('before_loader_setup.cnfs') do |event|
            add_inflectors(event.payload[:loader])
          end
          ActiveSupport::Notifications.subscribe('add_console_shortcuts.cnfs') do |event|
            add_console_shortcuts(event.payload[:shortcuts])
          end
        end

        def add_inflectors(loader)
          Cnfs.logger.info '[Aws] Configuring loader'

          loader.inflector.inflect(
            'acm' => 'ACM',
            'ec2' => 'EC2',
            'eks' => 'EKS',
            'rds' => 'RDS',
            'dbinstance' => 'DBInstance',
          )
        end

        def add_console_shortcuts(shortcuts)
          Cnfs.logger.info '[Aws] Adding console shortcuts'
          shortcuts.merge!({
            acm: Resource::Aws::ACM::Certificate,
            ec2: Resource::Aws::EC2::Instance,
            eks: Resource::Aws::EKS::Cluster,
            rds: Resource::Aws::RDS::DBInstance,
            s3: Resource::Aws::S3::Bucket,
            vpc: Resource::Aws::EC2::Vpc,
          })
        end

        def gem_root
          CnfsCli::Aws.gem_root
        end

        # TODO: Copy in blueprints, etc
        def customize
        end
      end
    end
  end
end
