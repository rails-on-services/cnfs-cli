# frozen_string_literal: true

module SolidRecord
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  class Node < ApplicationRecord
    belongs_to :parent, class_name: 'SolidRecord::Node'

    store :config, coder: YAML

    def bname() = pathname.basename.to_s

    def pathname() = @pathname ||= Pathname.new(path)

    def self.create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :parent
        t.string :path
        t.string :type
        t.string :config
      end
    end
  end
end
