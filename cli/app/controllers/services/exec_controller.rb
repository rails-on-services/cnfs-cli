# frozen_string_literal: true

module Services
  class ExecController < ApplicationController
    # cnfs exec iam ls -l -R
    def execute
      application.exec(application.service, application.arguments.command_args.join(' '), true)
    end
  end
end
