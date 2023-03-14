# frozen_string_literal: true

class Terraform::Provisioner < OneStack::Provisioner
  store :config, accessors: %i[state_file]

  before_validation :set_defaults

  def set_defaults
    self.state_file ||= 'terraform.tfstate'
  end

  # Provisioner API
  def deploy
    if context.options.dry_run
      binding.pry
      RubyTerraform.plan(**default_options) #, out: 'network.tfplan')
    else
      binding.pry
      RubyTerraform.apply(**default_options)
    end
  end

  def undeploy
    # Trigger a read of the file before running destroy so Plan can do a diff on it
    previous_state.content
    if context.options.dry_run
      binding.pry
      RubyTerraform.plan(**default_options) #, out: 'network.tfplan')
    else
      # RubyTerraform.destroy(**default_options)
    end
  end

  # The manifest will exclude these files
  def target_exclude_files() = ['terraform.tfstate']

  def previous_state() = @previous_state ||= Terraform::State.new(path: state_file_path)
  # def previous_state() = @previous_state ||= Terraform::State.new(path: Pathname.new('/tmp').join(state_file))

  def state() = @state ||= Terraform::State.new(path: state_file_path)

  def state_file_path() = path.join(state_file)

  private

  def default_options() = { chdir: path, auto_approve: true, json: true }

  # def show() = rt_exec(:show)

  # def rt_exec(cmd)
  #   io = StringIO.new
  #   rt_class(cmd).new(stdout: io).execute(rt_options)
  #   io.string
  # end

  # def rt_class(cmd) = "ruby_terraform/commands/#{cmd}".classify.constantize

  # def rt_options() = { chdir: @path.to_s, json: true }

  # def output() = @output ||= JSON.parse(raw_output).with_indifferent_access

  # def raw_output() = @raw_output ||= RubyTerraform.output(**default_options)

  # TODO: Merge with state
  # def state_output
  #   @state_output ||= with_captured_stdout { RubyTerraform.show(chdir: path, json: true) }
  # end

  # def with_captured_stdout
  #   original_stdout = $stdout  # capture previous value of $stdout
  #   $stdout = StringIO.new     # assign a string buffer to $stdout
  #   yield                      # perform the body of the user code
  #   $stdout.string             # return the contents of the string buffer
  # ensure
  #   $stdout = original_stdout  # restore $stdout to its previous value
  # end

  # def template_contents
  #   ERB.new(File.read(template_file), trim_mode: '-').result(blueprint._binding)
  # end
end
