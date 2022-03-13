# frozen_string_literal: true

module OneStack
  class Image < ApplicationRecord
    # Define operator before inclding Concerns::Target
    def self.operator() = OneStack::Builder

    include OneStack::Concerns::Target
    include Hendrix::Git

    belongs_to :builder
    belongs_to :registry
    belongs_to :repository

    # TODO: Move all of this up to delegation command to Compose::Image
    # As these things will be very different for e.g. Packer images
    # NOTE: dockerfile is relative to repository.git_path
    store :config, accessors: %i[args dockerfile tag]

    serialize :test_commands, Array

    before_validation :set_defaults

    def set_defaults
      return unless Node.source.eql?(:asset)

      self.dockerfile ||= 'Dockerfile'
    end

    # Concerns::Git methods require #git_path to be defined in order to behave as expected
    # NOTE: Templates can use image.git.tag or any other value from methods in Concerns::Git
    delegate :git_path, to: :repository

    class << self
      def add_columns(t)
        t.references :builder
        t.string :builder_name
        t.references :registry
        t.string :registry_name
        t.references :repository
        t.string :repository_name
        t.string :test_commands
        # t.string :build
        # t.string :path
      end
    end
  end
end
