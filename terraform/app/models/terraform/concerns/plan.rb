# frozen_string_literal: true

module Terraform
  module Concerns
    module Plan
      extend ActiveSupport::Concern

      included { table_mod :terraform_add_columns }

      class_methods do
        def terraform_add_columns(t)
          # t.string :terraform
          # t.string :providers
          t.string :variables
          t.string :modules
          t.string :outputs
        end
      end
    end
  end
end
