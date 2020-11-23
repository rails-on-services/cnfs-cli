# frozen_string_literal: true

module Services
  class AttachController
    include ServicesHelper
    attr_accessor :service

    def execute
      system(*service.attach.take(2))
    end
  end
end
