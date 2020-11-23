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
      dest_service = dest.to_s.include?(':')
      raise Cnfs::Error, 'only one of source or destination can be a service' if src_service && dest_service

      raise Cnfs::Error, 'one of source or destination must be a service' unless src_service || dest_service

      # set args.service so super_before_execute can find and set it
      @args = args.merge(service: src.index(':') ? src.split(':')[0] : dest.to_s.split(':')[0])
      super_before_execute
    end

    # TODO: This works, but it's a mess and it creates directories on local project even if file copy fails
    def execute
      if args.dest.class.name.eql?('Pathname')
        n = args.dest.to_s.delete_prefix(project.write_path(:services).to_s).delete_prefix('/')
        w = project.write_path(:services).join(service.name)
        w.join(Pathname.new(n).split.first).mkpath
        @args = args.merge('dest' => w.join(n).to_s)
      end
      cmd = service.copy(args.src, args.dest)
      Cnfs.logger.info cmd.join("\n")
      result = command.run!(*cmd)
      raise Cnfs::Error, result.err if result.failure?

# Signal.trap('INT') do
#   warn("\n#{caller.join("\n")}: interrupted")
#   # exit 1
# end

    end
  end
end
