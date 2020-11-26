# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module Aws
  module Infra
    module AddController
      extend ActiveSupport::Concern

      included do
        desc 'aws', 'Add AWS infrastructure to the environment'
        def aws
          require 'tty-prompt'
				  require 'aws-sdk-ec2'
          choices = %w(ec2 eks)
          cluster = prompt.enum_select('Cluster:', choices)
          results = {}

          if cluster.eql?('ec2')
            # binding.pry
            results[:ec2] = {}
            offerings = ec2_client(region: 'ap-southeast-1').describe_instance_type_offerings[0].map { |o| o.instance_type }
            choices = offerings.map {|c| c.split('.').first[0..1]}.uniq.sort
            family = prompt.enum_select('Instance type:', choices, per_page: choices.size)
            types = offerings.select {|c| c.start_with?(family) }.sort
            type = results[:ec2][:instance_type] = prompt.enum_select('Intance type:', types, per_page: types.size)
            results[:ec2][:key_name] = prompt.ask('key name:')
            results[:ec2][:eip] = prompt.yes?('Add an elastic IP?')

            if (alb = prompt.yes?('Add an ALB?'))
              results[:alb] = {}
            end
          elsif cluster.eql?('eks')
            results[:eks] = {}
            choices = %w(global_accelerator)
            results[:eks][:choices] = prompt.multi_select('Instance Options:', choices)
          end

          if (vpc = prompt.yes?('Add a VPC?'))
            results[:vpc] = {}
            regions = ec2_client.describe_regions[0].map { |r| r.region_name }
            region = results[:vpc][:region] = prompt.enum_select('Region:', regions, per_page: regions.size)
            azs = ec2_client(region: region).describe_availability_zones[0].map { |z| z.zone_name }
            results[:vpc][:azs] = prompt.multi_select('Availabiity Zones:', azs)
          end

          #   choices = %w(alb acm eip)

          if (db = prompt.yes?('Add a Database?'))
            results[:db] = {}
            choices = %w(rds aurora)
            results[:db][:type] = prompt.enum_select('Database:', choices)
          end

          if (dw = prompt.yes?('Add a Data Warehouse?'))
            results[:dw] = {}
            choices = %w(dms glue redshift)
            results[:dw][:options] = prompt.multi_select('Warehoue infrastructure:', choices)
          end

          bp = Blueprint::Aws::Instance.new
          bp.vpc = results[:vpc]
          # TODO: Write this out at as a blueprint which can be converted to JSON for terraform
          # binding.pry
          puts results
        end
      end

      private

      def prompt
        TTY::Prompt.new
      end

      def ec2_client(region: 'us-east-1')
        Aws::EC2::Client.new(region: region)
      end

      def ec2_resource(region: 'us-east-1')
        Aws::EC2::Resource.new(region: region)
      end
    end
  end
end
