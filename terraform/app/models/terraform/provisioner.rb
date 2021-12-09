# frozen_string_literal: true

class Terraform::Provisioner < Provisioner
  # Provisioner API
  def deploy
    if context.options.dry_run
      binding.pry
      RubyTerraform.plan(**default_options) #, out: 'network.tfplan')
    else
      # RubyTerraform.apply(**default_options)
      # st = ''
      # state = Dir.chdir(context.manifest.write_path) do
      state = JSON.parse(File.read(state_file)).with_indifferent_access if state_file.exist?
      # {}.with_indifferent_access
      # end
      # plans.each do |plan|
      #   plan.tf_state = test
      #   plan.create_resources #(state)
      # end
    end
  end

  def state_file() = path.join('terraform.tfstate')

  def undeploy
    RubyTerraform.destroy(**default_options)
  end

  private

  def output() = @output ||= JSON.parse(raw_output).with_indifferent_access

  def raw_output() = @raw_output ||= RubyTerraform.output(**default_options)

  # TODO: Merge with state
  def state_output
    @state_output ||= with_captured_stdout { RubyTerraform.show(chdir: path, json: true) }
  end

  def with_captured_stdout
    original_stdout = $stdout  # capture previous value of $stdout
    $stdout = StringIO.new     # assign a string buffer to $stdout
    yield                      # perform the body of the user code
    $stdout.string             # return the contents of the string buffer
  ensure
    $stdout = original_stdout  # restore $stdout to its previous value
  end

  def default_options() = { chdir: path, auto_approve: true, json: true }


  # def template_contents
  #   ERB.new(File.read(template_file), trim_mode: '-').result(blueprint._binding)
  # end

  # def required_tools
  #   %w[terraform]
  # end
end
