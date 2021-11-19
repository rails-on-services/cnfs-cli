# frozen_string_literal: true

class Terraform::Provisioner < Provisioner
  include Concerns::PlatformRunner
  # store :providers, accessors: %i[aws gcp azure], coder: YAML

  # Template helpers
  def output(resource, key)
    "output \"#{title(resource.name, key)}\" {
    value = #{module_attr(resource, key)}
  }"
  end

  def module_attr(resource, key)
    "module.#{title(resource.name)}.#{key}"
  end

  # Convert any '-' in the keys to '_' then join each key with '-' so can use split('-') to parse keys
  def title(*vars)
    vars.unshift(name).map { |key| key.gsub('-', '_') }.join('-')
  end
  # End Template helpers

  def prepare
    download_dependencies
  end

  def generate
    write_template
  end

  def write_template
    destination_path.mkpath unless destination_path.exist?
    File.open(destination_path.join('main.tf'), 'w') { |f| f.write(template_contents) }
  end

  def destination_path
    project.path(to: :templates).join(blueprint.name)
  end

  def template_contents
    ERB.new(File.read(template_file), trim_mode: '-').result(blueprint._binding)
  end

  def template_file
    blueprint.internal_path.to_s.gsub('/models/', '/views/').delete_suffix('.rb').concat('/terraform/main.tf.erb')
  end

  # def required_tools
  #   %w[terraform]
  # end

  # before_execute :hello
  # Commands called by ExecControllers
  def init
    run_callbacks :execute do
      # binding.pry
    end
    # rv('terraform init')
  end

  def plan
    rv('terraform plan')
  end

  # TODO: auto-approve should be a configuration option of the builder
  def apply
    rv('terraform apply -auto-approve')
  end

  def destroy
    rv('terraform destroy -auto-approve')
  end

  # command support methods
  # TODO: this is specific to AWS
  def command_env
    # {} # .merge(provider.command_env)
    # TODO: relook at how the aws creds and details are loaded and referenced
    { 'AWS_DEFAULT_REGION' => blueprint.provider.region }
  end
end
