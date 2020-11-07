# frozen_string_literal: true

class InfraController < CommandsController
  # namespace :infra

  # desc 'create', 'Create target infrastructure'
  # def create(*args); run(:create, args) end

  desc 'generate', 'Generate target infrastructure'
  def generate(*_args)
    run(:generate)
  end

  desc 'plan', 'Show the terraform infrastructure plan'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
    type: :boolean
  option :init, desc: 'Force to download latest modules from TF registry',
    type: :boolean
  def plan(*args)
    run(:plan, args)
  end

  desc 'apply', 'Apply the terraform infrastructure plan'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
    type: :boolean
  def apply(*args)
    run(:apply, args)
  end

  # desc 'show', 'Show infrastructure details'
  # def show(type = 'json')
  #   Dir.chdir(infra.deploy_path) do
  #     show_json
  #   end
  # end

  desc 'destroy', 'Destroy infrastructure'
  def destroy
    run(:destroy)
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
      Ros::Be::Infra::Generator.new([], {}, behavior: :revoke).invoke_all
      Ros::Be::Infra::Generator.new.invoke_all
    end
  end

  def show_json
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
