# frozen_string_literal: true

module Services
  class ExecController
    include ServicesHelper
    attr_accessor :service

    # cnfs service exec iam ls -l -R
    def execute
      command.run(*service.exec(args.command))
    end
  end
end
