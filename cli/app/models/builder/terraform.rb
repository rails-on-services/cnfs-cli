# frozen_string_literal: true

class Builder::Terraform < Builder
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
    ERB.new(IO.read(template_file), trim_mode: '-').result(blueprint._binding)
  end

  def template_file
    blueprint.internal_path.to_s.gsub('/models/', '/views/').delete_suffix('.rb').concat('/main.tf.erb')
  end

  # def required_tools
  #   %w[terraform]
  # end

  # Commands called by ExecControllers
  def init
    rv('terraform init')
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
