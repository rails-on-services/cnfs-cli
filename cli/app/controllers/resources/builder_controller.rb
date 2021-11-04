# frozen_string_literal: true

module Resources
  class BuilderController
    include ResourcesHelper

    def create
      binding.pry
    end

    def destroy
      binding.pry
    end

    # from plan_controller
    # def plan
    #   run_in_path(:init)
    #   run_in_path(:plan) do |result|
    #     raise Cnfs::Error, result.err if result.failure?
    #   end
    # end

    def apply
      # run_in_path(:init, :apply) do |result|
      # end
        # binding.pry
        # context.runtime.init.run! if context.options.init
        # # system_cmd('rm -f .terraform/terraform.tfstate')
        # context.runtime.apply.run!
      Dir.chdir(builder.destination_path) do
        result = command.run!('terraform output -json > output.json')
      end
      show_json
    end

    def show_json
      file = builder.destination_path.join('output.json')
      return unless file.exist?

      json = JSON.parse(File.read(file))
      json.each do |key, values|
        bp, res, att = key.split('-')
        reso = blueprint.resources.find_by(name: res)
        reso.send("#{att}=", values['value'].first)
        reso.save
      end

      # TODO: This will need to change for two things:
      # 1. when deploying to cluster these values will be different
      # 2. when deploying to another provider these keys will be different
      # if json['public-ip']
      #   ip = json['public-ip']['value'].first
      #   STDOUT.puts "ssh -A admin@#{ip}"
      # end
      # STDOUT.puts "API endpoint: #{json['lb_route53_record']['value'][0]['fqdn']}" if json['lb_route53_record']
      true
    end
  end
end
