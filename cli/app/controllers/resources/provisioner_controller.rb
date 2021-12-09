# frozen_string_literal: true

module Resources
  class ProvisionerController
    include Concerns::ExecController

    def create
      context.plan_provisioners.each do |provisioner|
        provisioner.execute(:deploy)
        # provisioner.create do |queue|
        # binding.pry
        # end
      end
    end

    # TODO: Lookup the resource which is what returns the thing to do, e.g. ssh for an EC2
    def connect
      binding.pry
    end

    def instance_shell
      # execute(ip: 'admin@18.136.156.168', controller: :provisioner, method: :connect)
      system("ssh -A #{args.ip}")
      # unless service.shell_command
      #   raise Cnfs::Error, "#{service.name} does not implement the shell command"
      # end

      # system(*service.shell.take(2))
    end

    def destroy
      context.plan_provisioners.each do |provisioner|
        provisioner.execute(:deploy)
        # provisioner.destroy do |queue|
        # binding.pry
        # end
      end
    end
  end
end
