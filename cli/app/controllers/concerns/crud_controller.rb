# frozen_string_literal: true

module Concerns
  module CrudController
    extend ActiveSupport::Concern
    include Cnfs::Concerns::ExecController

    included do
      extend Cnfs::Concerns::ExecController

      define_model_callbacks :execute
    end

    # Shortcut for CRUD controller's create and update methods
    # Ex: crud_with(Build.new(project: Cnfs.project))
    def crud_with(obj, location = 1)
      method = caller_locations(1, location)[location - 1].label
      obj.view.send(method)
      return obj if obj.save

      $stdout.puts obj.errors.map(&:full_message).join("\n")
    end
  end
end
