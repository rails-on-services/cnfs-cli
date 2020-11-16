# frozen_string_literal: true

module CnfsBackend
  module Services
    class AddController < Thor
      include Cnfs::Options
      include ::Services::AddConcern

      def self.description
        'Add a CNFS backend service'
      end

      # Activate common options
      cnfs_class_options :noop, :quiet, :verbose, :force

      desc 'iam', 'Add IAM Service'
      # TODO: Add the configuration for the service requested
      # Q: Is rails gem, cnfs repo or both responsible for the configuration files?
      def iam(name = nil)
        binding.pry
      end
    end
  end
end
