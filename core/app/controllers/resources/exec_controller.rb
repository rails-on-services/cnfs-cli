# frozen_string_literal: true

module Resources
  class ExecController
    include Concerns::ExecController

    # TODO: Lookup the resource which is what returns the thing to do, e.g. ssh for an EC2
    def console
      warn = nil
      if (res = context.resources.find_by(name: args.resource))
        if res.respond_to?(:console)
          res.console
        else
          warn = "Resource #{resource} does not implement 'console'"
        end
      else
        warn = "Resource #{resource} not found"
      end
      Cnfs.logger.warn(warn) if warn
    end
  end
end
