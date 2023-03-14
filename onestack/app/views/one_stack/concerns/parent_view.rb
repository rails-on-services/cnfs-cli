# frozen_string_literal: true

# Common Functionallity for Component and Asset
module OneStack
  module Concerns::ParentView
    extend ActiveSupport::Concern

    included do
      attr_accessor :context, :component
    end

    # @context is the current context
    def initialize(**options)
      @context = options.delete(:context)
      @component = @context&.component
      super
    end

    # Override base class
    def view_class_options() =  super.merge(context: context)

    # Override base class
    def options() = context&.options || {}

    # Cnfs::Core.asset_names.each do |asset_name|
    #   define_method("#{asset_name.singularize}_names".to_sym) do
    #     component.send("#{asset_name.singularize}_names".to_sym)
    #   end
    # end
  end
end
