# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.inheritance_column = 'kind'
end

module OneStack
  class Segment < ApplicationRecord
    include SolidRecord::Model

    store :config, accessors: %i[segments_type], coder: YAML

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          # t.solid
          t.string :name
        end
      end
    end
  end

  class Dependency < Segment; end

  class Plan < Segment; end

  class Provider < Segment; end

  class Provisioner < Segment; end

  class Repository < Segment; end

  class Environment < Segment; end

  class Service < Segment; end
end
