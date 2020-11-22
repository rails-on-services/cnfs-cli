# frozen_string_literal: true

module Services
  class CopyController
    include ServicesHelper
    alias_method :super_before_execute, :before_execute
    attr_accessor :service

    def before_execute
      src = args.src
      dest = args.dest
      src_service = src.include?(':')
      dest_service = dest.include?(':')
      raise Cnfs::Error, 'only one of source or destination can be a service' if src_service && dest_service

      raise Cnfs::Error, 'one of source or destination must be a service' unless src_service || dest_service

      @args = args.merge(service: src.index(':') ? src.split(':')[0] : dest.split(':')[0])
      super_before_execute
    end

    def execute
      # TODO: Fail if the container is not running
      command.run(*service.copy(args.src, args.dest))
    end
  end
end
