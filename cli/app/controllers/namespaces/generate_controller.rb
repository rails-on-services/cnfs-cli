# frozen_string_literal: true

module Namespaces
  class GenerateController
    include ExecHelper

    def execute
      project.process_manifests
    end
  end
end
