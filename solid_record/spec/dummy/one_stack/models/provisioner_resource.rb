# frozen_string_literal: true

module OneStack
  class ProvisionerResource < ApplicationRecord
    belongs_to :provisioner

    # accessors match the columns returned by docker ps
    # TODO: move this to a terraform concern
    # TODO: do the same for compose/docker and skaffold/docker
    store :terraform, coder: YAML, accessors: %i[rid image names command labels status ports]

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :provisioner
          # t.string :terraform
          # t.string :pulumi
        end
      end
    end
  end
end
