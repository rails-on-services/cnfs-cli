# frozen_string_literal: true

class NodeConfig < ApplicationRecord
  serialize :asset_names, Array
  serialize :component_names, Array

  before_validation :set_realpath

  def set_realpath
    self.realpath ||= Pathname.new(path).realpath.to_s
  end

  def rootpath
    @rootpath ||= Pathname.new(realpath)
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :path
        t.string :realpath
        t.string :asset_names
        t.string :component_names
      end
    end
  end
end
