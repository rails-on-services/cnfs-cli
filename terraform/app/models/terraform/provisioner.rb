# frozen_string_literal: true

class Terraform::Provisioner < Provisioner
  # TODO: This is not working
  # before_execute :hello

  def around_execute
    generate
    yield
  end

  # Provisioner API
  def create
    around_execute do
      if context.options.dry_run
        binding.pry
        RubyTerraform.plan(**default_options) #, out: 'network.tfplan')
      else
        binding.pry
        # RubyTerraform.apply(**default_options)
        # st = ''
        # state = Dir.chdir(context.manifest.write_path) do
        state = JSON.parse(File.read('terraform.tfstate')).with_indifferent_access
          # {}.with_indifferent_access
        # end
        context_plans.each do |plan|
          plan.tf_state = test
          plan.create_resources #(state)
        end
      end
    end
  end

  def destroy
    around_execute do
      RubyTerraform.destroy(**default_options)
    end
  end

  def output() = @output ||= JSON.parse(raw_output).with_indifferent_access

  def raw_output() = @raw_output ||= RubyTerraform.output(**default_options)

  # TODO: Merge with state
  def state_output
    @state_output ||= with_captured_stdout { RubyTerraform.show(chdir: context.manifest.write_path, json: true) }
  end

  def with_captured_stdout
    original_stdout = $stdout  # capture previous value of $stdout
    $stdout = StringIO.new     # assign a string buffer to $stdout
    yield                      # perform the body of the user code
    $stdout.string             # return the contents of the string buffer
  ensure
    $stdout = original_stdout  # restore $stdout to its previous value
  end

  # def default_options() = { chdir: context.manifest.write_path, auto_approve: true, json: true }
  def default_options() = { auto_approve: true, json: true }


  # def template_contents
  #   ERB.new(File.read(template_file), trim_mode: '-').result(blueprint._binding)
  # end

  # def required_tools
  #   %w[terraform]
  # end
end
