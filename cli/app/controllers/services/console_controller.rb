# frozen_string_literal: true

module Services
  class ConsoleController < ApplicationController
    def execute
      unless application.service.respond_to?(:console_command)
        raise Cnfs::Error, "#{application.service.name} does not implement the console command"
      end

      application.runtime.exec(application.service, application.service.console_command, true).run!
    end
  end
end
