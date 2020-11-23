# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module Aws
  module Infra
    class AddController < Thor
      include CommandHelper

      # cnfs_class_options :environment
      # class_option :namespace, desc: 'Target namespace',
      #   aliases: '-n', type: :string
      cnfs_class_options :dry_run, :logging

      desc 'ec2 NAME', 'Add a CNFS compatible blueprint for AWS EC2'
      option :alb, desc: 'Frontend EC2 with an ALB',
                   aliases: '-a', type: :boolean
      option :rds, desc: 'Add and RDS backend',
                   aliases: '-r', type: :boolean
      def ec2(name)
        binding.pry
      end

      desc 'eks NAME', 'Add a CNFS compatible blueprint for AWS EKS'
      # option :alb, desc: 'Frontend EC2 with an ALB',
      #   aliases: '-a', type: :boolean
      # option :rds, desc: 'Add and RDS backend',
      #   aliases: '-r', type: :boolean
      def eks(name)
        binding.pry
      end
    end
  end
end
