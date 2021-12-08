# frozen_string_literal: true

module Resources
  class ProvisionerController
    include ResourcesHelper

    def create
      run_callbacks :execute do
        context.plan_provisioners.each do |provisioner|
          provisioner.create do |queue|
            # binding.pry
          end
        end
      end
    end

    # TODO: Lookup the resource which is what returns the thing to do, e.g. ssh for an EC2
    def connect
      run_callbacks :execute do
        binding.pry
      end
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
      run_callbacks :execute do
        context.plan_provisioners.each do |provisioner|
          provisioner.destroy do |queue|
            # binding.pry
          end
        end
      end
    end
  end
end
