# frozen_string_literal: true

module Cnfs
  module Aws
    class Plugin < Cnfs::Plugin
      initializer 'add console shortcuts' do |app|
        Cnfs.logger.info('[Aws] Initializing from', gem_root)

        Cnfs.subscribers << ActiveSupport::Notifications.subscribe('add_console_shortcuts.cnfs') do |event|
          add_console_shortcuts(event.payload[:shortcuts])
        end
      end

      class << self
        def before_loader_setup(loader)
          add_inflectors(loader)
        end

        def add_inflectors(loader)
          Cnfs.logger.info '[Aws] Configuring loader'

          loader.inflector.inflect(
            'acm' => 'ACM',
            'ec2' => 'EC2',
            'eks' => 'EKS',
            'rds' => 'RDS',
            'dbinstance' => 'DBInstance',
            'dbinstance_view' => 'DBInstanceView',
          )
        end

        def add_console_shortcuts(shortcuts)
          Cnfs.logger.info '[Aws] Adding console shortcuts'
          shortcuts.merge!(
            acm: ::Aws::Resource::ACM::Certificate,
            ec2: ::Aws::Resource::EC2::Instance,
            eks: ::Aws::Resource::EKS::Cluster,
            rds: ::Aws::Resource::RDS::DBInstance,
            s3: ::Aws::Resource::S3::Bucket,
            vpc: ::Aws::Resource::EC2::Vpc
          )
        end

        def gem_root() = Cnfs::Aws.gem_root
      end
    end
  end
end
