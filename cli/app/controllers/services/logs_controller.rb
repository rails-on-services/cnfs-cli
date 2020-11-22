# frozen_string_literal: true

module Services
  class LogsController
    include ServicesHelper
    attr_accessor :service

    def execute
      trap('SIGINT') { throw StandardError } if options.tail
      command.run(*service.logs)
    rescue StandardError
    end
  end
end
