# frozen_string_literal: true

module Concerns
  module CrudController
    extend ActiveSupport::Concern
    include Concerns::CommandController

    # rubocop:disable Metrics/BlockLength
    included do
      extend Concerns::CommandController

      action = name.demodulize.delete_suffix('Controller') # create list show edit destroy
      method = action.downcase.to_sym

      # cnfs_class_options :dry_run, :quiet, :clean
      cnfs_class_options Cnfs.config.segments.keys

      Cnfs::Core.asset_names.dup.append('components').each do |asset_name|
        model_class_name = asset_name.classify # Plan Provisioner Service User

        command_name = method.eql?(:list) ? asset_name : asset_name.singularize
        command_hint = method.eql?(:list) ? 'PATTERN' : 'NAME'
        command_desc = method.eql?(:list) ? model_class_name.pluralize : model_class_name

        if method.eql?(:list)
          class_option :edit, desc: "Choose a #{model_class_name} to edit from the list", type: :boolean
          class_option :show, desc: "Choose a #{model_class_name} to show from the list", type: :boolean
          class_option :destroy, desc: "Choose a #{model_class_name} to destroy from the list", type: :boolean
        end
        desc "#{command_name} [#{command_hint}]", "#{action} #{command_desc}"

        # rubocop:disable Metrics/MethodLength
        define_method(command_name) do |name = nil|
          model = models = nil
          # component = Component.list(options).last
          context = Component.context_from(options)

          if method.eql?(:create)
            model = model_class_name.constantize.new(name: name, owner: component)
          elsif method.eql?(:list)
            models = context.component.send(asset_name.to_sym)
            models = models.where('name LIKE ?', "%#{name}%") if name
          else # :show, :edit, :destroy
            unless (model = context.component.send(asset_name.to_sym).find_by(name: name))
              Cnfs.logger.warn(model_class_name, name, 'not found')
              return
            end
          end

          view_class_name = "#{model_class_name}View"
          view_class = view_class_name.safe_constantize
          raise Cnfs::Error, "#{view_class_name} not found. This is a bug. Please report." unless view_class

          view_class.new(model: model, models: models, context: context).send(method)
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
