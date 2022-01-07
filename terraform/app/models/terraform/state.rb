# frozen_string_literal: true

module Terraform
  class StateHash < Thor::CoreExt::HashWithIndifferentAccess; end

  class State
    include ActiveModel::AttributeAssignment

    attr_accessor :path

    delegate :lineage, :outputs, :resources, :serial, :terraform_version, :version, to: :content

    def initialize(**options) = assign_attributes(**options)

    %i[resources outputs].each do |method|
      define_method("#{method.to_s.singularize}_keys") { content[method].map(&:type) }
    end

    def content() = @content ||= JSON.parse(raw_content, object_class: Terraform::StateHash) 

    private

    def raw_content() = @raw_content ||= path&.exist? ? File.read(path) : empty_hash.to_json

    def empty_hash
      {
        resources: [],
        outputs: {}
      }
    end
  end
end
