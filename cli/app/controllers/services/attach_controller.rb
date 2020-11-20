# frozen_string_literal: true

module Services
  class AttachController
    include ExecHelper

    def execute
      service = arguments[:services].pop
      return unless (so = Cnfs.app.services.find_by(name: service))

      puts so.runtime.attach(so)

      # binding.pry
      # so = Cnfs.app.services.where("name = '#{service}' and tags LIKE ?", rt)
      # return unless (service_obj = Cnfs.app.services.find_by(conditions))

      # super
      # run(:build) if options.build
      # runtime.attach.run!
    end
  end
end
