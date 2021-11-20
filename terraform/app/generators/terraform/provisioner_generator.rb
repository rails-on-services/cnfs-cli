# frozen_string_literal: true

class Terraform::ProvisionerGenerator < ProvisionerGenerator

  # Write all the resources into a main.tf using a single template for the blueprint
  # Later write stuff to the standing input and output files
  def hello
    # generated_files << template("#{blueprint.template}.tf.json.erb",
                                  # "#{path}/#{blueprint.template.split('/').last}.tf.json")
    runtime.context_resources.each do |resource|
      puts resource.to_hcl
    binding.pry
    end
  end

  private
  def blueprint_to_terraform_json
    project.environment.blueprints.each do |blueprint|
      unless blueprint.valid?
        Cnfs.logger.warn("Invalid blueprint #{blueprint.name}")
        next
      end

      @blueprint = blueprint
      generated_files << template("#{blueprint.template}.tf.json.erb",
                                  "#{path}/#{blueprint.template.split('/').last}.tf.json")
    end
    remove_stale_files
  end

  def excluded_files
    Dir[path.join('terraform-provider*')] + Dir[path.join('terraform.tfstate*')]
  end
end
