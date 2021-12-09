# frozen_string_literal: true

module Resources
  class CrudController
    include Concerns::ExecController

    def add
      run_callbacks :execute do
        binding.pry
      end
    end

    # This is an interactive session; See builder for some existing implementation code
    def create
      run_callbacks :execute do
        # res = Resource.new.create
        binding.pry
        # res.save
      end
    end

    def list
      run_callbacks :execute do
        puts context.resources.pluck(:name).join("\n")
      end
    end

    def show
      run_callbacks :execute do
        context.resources.each do |res|
          puts res.as_json
        # binding.pry
        # Dir.chdir(infra.deploy_path) do
        #   show_json
        end
      end
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

    def destroy
      run_callbacks :execute do
        binding.pry
        # run_in_path(:destroy) do |result|
        #   raise Cnfs::Error, result.err if result.failure?
        # end
      end
    end
  end
end
