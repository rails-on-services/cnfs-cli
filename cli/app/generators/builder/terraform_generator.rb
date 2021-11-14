# frozen_string_literal: true

class Builder::TerraformGenerator < BuilderGenerator
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

  private

  def excluded_files
    Dir[path.join('terraform-provider*')] + Dir[path.join('terraform.tfstate*')]
  end
end
