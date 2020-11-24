# frozen_string_literal: true

module Infra
  class ApplyController
    include InfraHelper

    def execute
      run_in_path(:apply) do |result|
        # binding.pry
        # context.runtime.init.run! if context.options.init
        # # system_cmd('rm -f .terraform/terraform.tfstate')
        # context.runtime.apply.run!
        result = command.run!('terraform output -json > output.json')
        show_json
      end
    end

    def show_json
      binding.pry
      return unless File.exist?('output.json')

      json = JSON.parse(File.read('output.json'))
      # TODO: This will need to change for two things:
      # 1. when deploying to cluster these values will be different
      # 2. when deploying to another provider these keys will be different
      if json['ec2-eip']
        ip = json['ec2-eip']['value']['public_ip']
        STDOUT.puts "ssh -A admin@#{ip}"
      end
      STDOUT.puts "API endpoint: #{json['lb_route53_record']['value'][0]['fqdn']}" if json['lb_route53_record']
    end
  end
end
