# frozen_string_literal: true

module Infra
  class PlanController < Cnfs::Command
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      # binding.pry
      # generate_config if stale_config
      Dir.chdir(target.write_path(:infra)) do
        runtime.init
        runtime.plan
      end
    end
  end
end

=begin
        desc 'init', 'Initialize the cluster'
        option :long, type: :boolean, aliases: '-l', desc: 'Run the long form of the command'
        option :role_name, type: :string, aliases: '--role-name', desc: 'Override the aws iam role to be used'
        def init
          cluster.init(self)
        end

        def initialize(*args)
          @errors = Ros::Errors.new
          super
        end

        desc 'plan', 'Show the terraform infrastructure plan'
        option :cl, type: :boolean, aliases: '--clear', desc: 'Clear local modules cache. Force to download latest modules from TF registry'
        def plan
          generate_config if stale_config
          Dir.chdir(infra.deploy_path) do
            fetch_terraform_custom_providers(infra.config.custom_tf_providers, options.cl)
            system_cmd('rm -rf .terraform/modules/') if options.cl
            system_cmd('terraform init', cmd_environment)
            system_cmd('terraform plan', cmd_environment)
          end
        end

        desc 'apply', 'Apply the terraform infrastructure plan'
        option :cl, type: :boolean, aliases: '--clear', desc: 'Clear local modules cache. Force to download latest modules from TF registry'
        def apply
          generate_config if stale_config
          Dir.chdir(infra.deploy_path) do
            fetch_terraform_custom_providers(infra.config.custom_tf_providers, options.cl)
            system_cmd('rm -rf .terraform/modules/') if options.cl
          end
        end

        desc 'show', 'Show infrastructure details'
        def show(type = 'json')
          Dir.chdir(infra.deploy_path) do
            show_json
          end
        end

        desc 'destory', 'Destroy infrastructure'
        def destroy
          Dir.chdir(infra.deploy_path) do
            fetch_terraform_custom_providers(infra.config.custom_tf_providers, options.cl)
            system_cmd('terraform destroy', {})
          end
        end

        private
        # TODO: this needs to be per provider and region comes from deployment.yml
        def cmd_environment
          { 'AWS_DEFAULT_REGION' => 'ap-southeast-1' }
        end

        def config_files
          Dir["#{Ros.root.join(infra.deploy_path)}/*.tf"]
        end

        def generate_config
          silence_output do
            Ros::Be::Infra::Generator.new([], {}, {behavior: :revoke}).invoke_all
            Ros::Be::Infra::Generator.new.invoke_all
          end
        end

        def show_json
          if File.exist?('output.json')
            json = JSON.parse(File.read('output.json'))
            # TODO: This will need to change for two things:
            # 1. when deploying to cluster these values will be different
            # 2. when deploying to another provider these keys will be different
            if json['ec2-eip']
              ip = json['ec2-eip']['value']['public_ip']
              STDOUT.puts "ssh -A admin@#{ip}"
            end
            if json['lb_route53_record']
              STDOUT.puts "API endpoint: #{json['lb_route53_record']['value'][0]['fqdn']}"
            end
          end
        end
=end
