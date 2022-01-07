# frozen_string_literal: true

module Packer
  module Concerns
    module BelongsToBuild
      extend ActiveSupport::Concern

      included do
        belongs_to :build, required: true

        # after_initialize :set_defaults

        # before_validation :set_defaults

        # validates :name, presence: true
        validates :order, presence: true

        # delegate :project, to: :build

        # parse_sources :project
        # parse_scopes :build
      end

      # def set_defaults
      #   raise NotImplementedError
      # end

      # def as_save
        # attributes.except('build_id', 'id', 'name')
      # end

      # def save_path
        # raise Cnfs::Error, 'Missing build' unless build

        # Cnfs.project.paths.config.join('builds', build.name, "#{self.class.table_name}.yml")
      # end
    end
  end
end
