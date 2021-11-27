# frozen_string_literal: true

require 'uri'

module Terraform
  module Blueprint
    extend ActiveSupport::Concern

    included do
      include Concerns::Operator
      table_mod :terraform_add_columns

      store :terraform, accessors: %i[modules], coder: YAML
      serialize :tf_modules, Array

      validate :tf_modules_are_urls
    end

    def tf_modules_are_urls
      return unless Node.source.eql?(:asset)

      tf_modules.each do |mod|
        errors.add(:url, mod) unless valid_url?(mod)
      end
    end

    def valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && !uri.host.nil?
    rescue URI::InvalidURIError
      false
    end

    def x_download
      # dependencies.each do |dependency|
      # dep = dependency[:url].cnfs_sub
      # Pathname.new('.terraform/modules').rmtree if options.clean
      url = tf_modules.last
      # g = git_clone(url)
      download(url, '/tmp')
      # binding.pry
      # path = '.terraform/modules'
    end

    class_methods do
      def terraform_add_columns(t)
        t.string :terraform
        t.string :tf_modules
      end
    end
  end
end
