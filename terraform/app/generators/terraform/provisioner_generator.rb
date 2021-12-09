# frozen_string_literal: true

class Terraform::ProvisionerGenerator < ProvisionerGenerator

  def manifests
    # cnfs_template('variables.tf')
    cnfs_template('main.tf')
    cnfs_template('outputs.tf')
  end

  def format_and_initialize
    # binding.pry
    RubyTerraform.format
    provisioner.plans.map(&:provider).each do |provider|
      next unless (url = provider.config[:url])

      # TODO: Here we can download the url to where it needs to go
      # See Operator
      Cnfs.logger.info "TODO: Implement download of #{url}"
    end
    RubyTerraform.init
  end

  def cleanup() = remove_stale_files

  private

  def internal_path() = Pathname.new(__dir__)

  # These values are rendered before the rest of the hash keys
  def pre_keys() = %w[source version]

  def excluded_files
    # Dir[path.join('terraform-provider*')] + Dir[path.join('terraform.tfstate*')]
    # path.glob('terraform-provider*') + path.glob('terraform.tfstate*')
    path.glob('.terraform*') + path.glob('terraform.tfstate*')
  end

  def with_captured_stdout
    original_stdout = $stdout  # capture previous value of $stdout
    $stdout = StringIO.new     # assign a string buffer to $stdout
    yield                      # perform the body of the user code
    $stdout.string             # return the contents of the string buffer
  ensure
    $stdout = original_stdout  # restore $stdout to its previous value
  end

  # # Template helpers
  # def output(resource, key)
  #   "output \"#{title(resource.name, key)}\" {
  #   value = #{module_attr(resource, key)}
  # }"
  # end

  # def module_attr(resource, key)
  #   "module.#{title(resource.name)}.#{key}"
  # end

  # Convert any '-' in the keys to '_' then join each key with '-' so can use split('-') to parse keys
  # def title(*vars)
  #   vars.unshift(name).map { |key| key.gsub('-', '_') }.join('-')
  # end
  # End Template helpers
end
