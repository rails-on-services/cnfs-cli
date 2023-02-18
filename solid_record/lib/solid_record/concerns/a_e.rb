# frozen_string_literal: true

module SolidRecord
  module AE
    extend ActiveSupport::Concern

    included do
      # Values are passed in from File and Association to Elements and passed on to model_class.create
      attr_accessor :values

      validates :model_class_name, presence: true

      delegate :pathname, :namespace, to: :root
    end

    # The class of the model managed (created, updated, destroyed) by an instance of Element
    def model_class(class_name = model_class_name)
      @model_class ||= retc(class_name) || retc(namespace, class_name) ||
                       SolidRecord.raise_or_warn(StandardError.new(to_json))
      # binding.pry if @model_class.nil?
      # @model_class
    end

    def retc(*ary) = ary.compact.join('/').classify.safe_constantize
  end
end
