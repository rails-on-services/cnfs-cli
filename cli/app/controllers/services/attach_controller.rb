# frozen_string_literal: true

module Services
  class AttachController
    include ServicesHelper
    attr_accessor :service

    def execute
      command.run(*service.attach)
    end
  end
end
