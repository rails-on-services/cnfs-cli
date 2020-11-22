# frozen_string_literal: true

module Images
  class BuildController
    include ServicesHelper
    attr_accessor :services

    def execute
      result = command.run!(*project.runtime.build(services))
      raise Cnfs::Error, result.err if result.failure?
    end
  end
end
