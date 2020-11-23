# frozen_string_literal: true

module Services
  class CopyController
    include ServicesHelper
    attr_accessor :service

    alias_method :super_before_execute, :before_execute

    def before_execute
      src = args.src
      dest = args.dest
      src_service = src.include?(':')
      dest_service = dest.include?(':')
      raise Cnfs::Error, 'only one of source or destination can be a service' if src_service && dest_service

      raise Cnfs::Error, 'one of source or destination must be a service' unless src_service || dest_service

      # set args.service so super_before_execute can find and set it
      @args = args.merge(service: src.index(':') ? src.split(':')[0] : dest.split(':')[0])
      super_before_execute
    end

    def execute
      cmd = service.copy(args.src, args.dest)
      # Cnfs.logger.info cmd.join("\n")
      result = command.run!(*cmd)
      raise Cnfs::Error, result.err if result.failure?
    end
  end
end
