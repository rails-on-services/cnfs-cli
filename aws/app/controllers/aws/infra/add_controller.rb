# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module Aws
  module Infra
    module AddController
      extend ActiveSupport::Concern
      attr_reader :region

      included do
        desc 'aws', 'Add AWS infrastructure to the environment'
        def aws
          require 'tty-prompt'
          do_it if prompt.yes?('Are you sure?')
        end
      end

      private

      def do_it
        begin
          regions = ec2_client.describe_regions[0].map { |r| r.region_name }.sort
          @region = prompt.enum_select('Region:', regions, per_page: regions.size)
        rescue Aws::EC2::Errors::AuthFailure => e
          raise Cnfs::Error, e.message
        end
        res = Aws::Resource::Acm.new
        res.configure(region: region)
        certs = res.list_certificates
        binding.pry
        res = Aws::Resource::Route53.new
        res.configure(region: region)
        zones = res.hosted_zones.map {|zone| zone.name }
        this = prompt.enum_select('Zone:', zones, per_page: zones.size)
        # res.save
        binding.pry
        choices = %w(ec2 eks)
        cluster = prompt.enum_select('Cluster:', choices)

        configure_ec2 if cluster.eql?('ec2')
        configure_eks if cluster.eql?('eks')

        configure_vpc if prompt.yes?('Add a VPC?')
        configure_rds if prompt.yes?('Add a Database?')
        configure_redshift if prompt.yes?('Add a Data Warehouse?')
      end

      def configure_ec2
        res = Aws::Resource::Instance.new
        res.configure(region: region)
        res.save
        # if (alb = prompt.yes?('Add an ALB?'))
        #   results[:alb] ||= {}
        # end
      end

      def configure_eks
        results[:eks] ||= {}
        choices = %w(global_accelerator)
        results[:eks][:choices] = prompt.multi_select('Instance Options:', choices)
      end

      def configure_vpc
        res = Aws::Resource::Vpc.new
        res.configure(region: region)
        binding.pry
        res.save
      end

      def configure_rds
        res = Aws::Resource::Database.new
        res.configure(region: region)
        res.save
        binding.pry
      end

      def configure_redshift
        res = Aws::Resource::Redshift.new
        res.configure(region: region)
        res.save
        binding.pry
      end

      # choices = %w(dms glue redshift)
      # bp = Blueprint::Aws::Instance.new
      # bp.vpc = results[:vpc]
      # # TODO: Write this out at as a blueprint which can be converted to JSON for terraform
      # # binding.pry
      # puts results

      def prompt
        TTY::Prompt.new
      end

      def ec2_client(region: 'us-east-1')
				require 'aws-sdk-ec2'
        Aws::EC2::Client.new(region: region)
      end

      def ec2_resource(region: 'us-east-1')
        Aws::EC2::Resource.new(region: region)
      end
    end
  end
end
