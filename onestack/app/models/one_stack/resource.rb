# frozen_string_literal: true

module OneStack
  class Resource < ApplicationRecord
    include OneStack::Concerns::Generic

    belongs_to :plan, optional: true
    belongs_to :provider, optional: true
    belongs_to :runtime, optional: true

    has_many :services

    # store :config, accessors: %i[source version], coder: YAML

    # store :envs, coder: YAML

    class << self
      def add_columns(t)
        t.references :plan
        t.string :plan_name
        t.references :provider
        t.string :provider_name
        t.references :runtime
        t.string :runtime_name
        # t.string :envs
      end
    end
  end
end
