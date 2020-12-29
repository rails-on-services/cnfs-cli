# frozen_string_literal: true

require 'cnfs_cli/aws/version'

module CnfsCli
  module Aws
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end

      def initialize
        Cnfs.logger.info "[Aws] Initializing from #{gem_root}"
      end

      def add_console_shortcuts(options)
        Cnfs.logger.info '[Aws] Adding console shortcuts'
        shortcuts = options.shift
        shortcuts.merge!({
          acm: Resource::Aws::ACM::Certificate,
          ec2: Resource::Aws::EC2::Instance,
          eks: Resource::Aws::EKS::Cluster,
          rds: Resource::Aws::RDS::DBInstance,
          s3: Resource::Aws::S3::Bucket,
          vpc: Resource::Aws::EC2::Vpc,
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
          'dbinstance' => 'DBInstance',
        )
      end

      # TODO: Copy in blueprints, etc
      def customize; end
    end
  end
end
