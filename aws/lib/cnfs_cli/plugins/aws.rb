# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Aws
      class << self
        def initialize_aws
          require 'cnfs_cli/aws'
          Cnfs.logger.info "[Aws] Initializing from #{gem_root}"
          Cnfs.subscribers << ActiveSupport::Notifications.subscribe('before_loader_setup.cnfs') do |event|
            add_inflectors(event.payload[:loader])
          end
          Cnfs.subscribers << ActiveSupport::Notifications.subscribe('add_console_shortcuts.cnfs') do |event|
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
            acm: ::Aws::Resource::ACM::Certificate,
            ec2: ::Aws::Resource::EC2::Instance,
            eks: ::Aws::Resource::EKS::Cluster,
            rds: ::Aws::Resource::RDS::DBInstance,
            s3: ::Aws::Resource::S3::Bucket,
            vpc: ::Aws::Resource::EC2::Vpc,
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
