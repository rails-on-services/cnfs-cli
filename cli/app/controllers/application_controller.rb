# frozen_string_literal: true

require 'forwardable'

class ApplicationController
  extend Forwardable

  def_delegators :command, :run

  attr_accessor :deployment, :application, :target, :runtime
  attr_accessor :args, :cli_args, :options, :request, :response
  attr_accessor :input, :output, :errors
  attr_accessor :result, :display

  # TODO: Integrate this method into standard flow
  def publish_results
    require 'tty-table'
    table = TTY::Table.new(['Commands', 'Errors'], errors.messages.to_a)
    output.puts "\n"
    output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
  end

  # TODO: Test
  def with_spinner(spin_msg)
    if options.quiet
      require 'tty-spinner'
      spinner = TTY::Spinner.new("[:spinner] #{spin_msg}", format: :pulse_2)
      spinner.auto_spin # Automatic animation with default interval
    end
    result = yield
    if options.quiet
      spinner_msg = result.failure? ? 'Failed!' : 'Done!'
      spinner.stop(spinner_msg)
    end
    errors.add(:build, result.err.chomp) if result.failure?
  end

  def initialize(args, options)
    @input = $stdin
    @output = $stdout
    @cli_args = args

    @args = Config::Options.new(Cnfs.context&.config(args) || args)
    Cnfs.key_name = args.key_name if args.key_name
    @options = options
    @errors = Cnfs::Errors.new
    if options.debug
      output.puts "ENVs: #{ENV.select { |env| env.start_with? 'CNFS_'}}\n" \
        "cli options: #{options}\ncli args: #{cli_args}\n" \
        "key name: #{Cnfs.key_name}\ncontext: #{Cnfs.context_name}\ncontext args: #{Cnfs.context&.to_args}\n" \
        "command args: #{@args.to_h}"
    end
    output.puts "WARN: encrypition key not found for key name '#{Cnfs.key_name}'" unless Cnfs.key
  end

  def each_target
    # check_limits(:deployments)
    deployments.each do |deployment|
      configure_target(deployment)
      output.puts "Running in #{target.exec_path}" if options.debug
      Dir.chdir(target.exec_path) do
      # check_limits(:services)
        yield target
      end
      configure_target
    end
  end

  # def check_limits(key)
  #   raise Cnfs::Error, "#{key} must be exactly #{limits[key]}" if limits[key] and send(key).size != limits[key]
  # end

  # def limits; {} end

  def deployments(query_args = nil); @deploymnets ||= configure_deployents(query_args) end

  def configure_deployents(query_args)
    query_args ||= args
    result = Deployment.all
    result = result.joins(:application).where(applications: { name: query_args.application_name }) if query_args.application_name
    result = result.joins(:target).where(targets: { name: query_args.target_name }) if query_args.target_name
    output.puts "selected deployments: #{result.pluck(:name).join(', ')}" if options.debug
    result
  end

  def configure_target(deployment = nil)
    if deployment.nil?
      @target = nil
      @request = nil
      @response = nil
      @runtime = nil
      return
    end

    @target = deployment.target
    @target.deployment = deployment
    @target.application = deployment.application

    @request = Request.new(deployment, args, options)
    output.puts "selected services: #{request.service_names_to_s}" if options.debug

    @response = Response.new(command_name, options, output, command(command_options), errors)

    # Set runtime object to an instance of compose or skaffold
    return unless (@runtime = current_runtime)

    # Set the runtime's request and response virtual attributes
    @runtime.request = request
    @runtime.response = response

    # Set the runtime's target virtual attribute to the current target
    # Runtime methods are called directly and some values are dependent upon the current target
    @runtime.target = target
  end

  def command_name; self.class.name.demodulize.underscore.delete_suffix('_controller') end

  def current_runtime
    mod = self.class.name.underscore.split('/').first
    return target.infra_runtime if mod.eql?('infra')
    target.runtime
  end

  def call(command = nil)
    if command.nil?
      execute
      return self
    end

    # binding.pry
    # Don't pass a command from the router; This is for command chaining
    replace_this = self.class.name.demodulize
    with_that = "#{command.to_s.camelize}Controller"
    controller_class = self.class.name.gsub(replace_this, with_that).safe_constantize
    controller = controller_class.new(args, options)
    controller.configure_target(target.deployment)
    controller.execute_on_target
  end

  # Execute this command
  #
  # @api public
  def execute
    raise NotImplementedError
  end

  def post_start_options
    if options.attach
      call(:attach)
    elsif options.shell
      call(:shell)
    elsif options.console
      call(:console)
    end
  end

  def before_execute_on_target
    runtime.before_execute_on_target
    call(:generate) if stale_config?
  end

  def stale_config?
    return false if config_files.empty?
    manifest_files.empty? || (last_config_file_updated > first_manifest_file_created)
    # Check template files
    # Dir["#{Ros.gem_root.join('lib/ros/be')}/**/{templates,files}/**/*"].each do |f|
    #   return true if mtime < File.mtime(f)
    # end
    # # Check custom templates
    # Dir["#{Ros.root.join('lib/generators')}/be/**/{templates,files}/**/*"].each do |f|
    #   return true if mtime < File.mtime(f)
    # end
  end

  def last_config_file_updated; config_files.map { |f| File.mtime(f) }.max end
  def config_files; Dir[Cnfs.config_path.join('**/*.yml')] end

  def first_manifest_file_created; manifest_files.map { |f| File.mtime(f) }.min end
  def manifest_files; Dir[target.write_path.join('**/*')] end

  # The external commands runner
  #
  # @see http://www.rubydoc.info/gems/tty-command
  #
  # @api public
  def command(**options)
    require 'tty-command'
    TTY::Command.new(options)
  end

  def command_options
    cmd_options = { uuid: false }
    cmd_options.merge!(dry_run: true) if options.noop
    cmd_options.merge!(printer: :null) if options.quiet
    cmd_options
  end

  # The cursor movement
  #
  # @see http://www.rubydoc.info/gems/tty-cursor
  #
  # @api public
  def cursor
    require 'tty-cursor'
    TTY::Cursor
  end

  # Open a file or text in the user's preferred editor
  #
  # @see http://www.rubydoc.info/gems/tty-editor
  #
  # @api public
  def editor
    require 'tty-editor'
    TTY::Editor
  end

  # File manipulation utility methods
  #
  # @see http://www.rubydoc.info/gems/tty-file
  #
  # @api public
  def generator
    require 'tty-file'
    TTY::File
  end

  # Terminal output paging
  #
  # @see http://www.rubydoc.info/gems/tty-pager
  #
  # @api public
  def pager(**options)
    require 'tty-pager'
    TTY::Pager.new(options)
  end

  # Terminal platform and OS properties
  #
  # @see http://www.rubydoc.info/gems/tty-pager
  #
  # @api public
  def host
    require 'tty-platform'
    TTY::Platform.new
  end

  # The interactive prompt
  #
  # @see http://www.rubydoc.info/gems/tty-prompt
  #
  # @api public
  def prompt(**options)
    require 'tty-prompt'
    TTY::Prompt.new(options)
  end

  # Get terminal screen properties
  #
  # @see http://www.rubydoc.info/gems/tty-screen
  #
  # @api public
  def screen
    require 'tty-screen'
    TTY::Screen
  end

  # The unix which utility
  #
  # @see http://www.rubydoc.info/gems/tty-which
  #
  # @api public
  def which(*args)
    require 'tty-which'
    TTY::Which.which(*args)
  end

  # Check if executable exists
  #
  # @see http://www.rubydoc.info/gems/tty-which
  #
  # @api public
  def exec_exist?(*args)
    require 'tty-which'
    TTY::Which.exist?(*args)
  end

  # class << self
  #   attr_accessor :callbacks

  #   def callbacks; @callbacks ||= {} end

  #   # define callback methods, e.g. :before_validate, :after_execute
  #   %i[before on after].each do |lifecycle|
  #     %i[validate execute finalize].each do |event|
  #       lifecycle_event = [lifecycle, event].join('_').to_sym
  #       define_method(lifecycle_event) do |callback_method|
  #         callbacks[lifecycle_event] ||= []
  #         if callbacks[lifecycle_event].include?(callback_method)
  #           STDOUT.puts "WARN: '#{callback_method}' #{lifecycle_event} callback already defined"
  #           return
  #         end
  #         callbacks[lifecycle_event].append(callback_method)
  #       end
  #     end
  #   end

  #   def run_callbacks(lifecycle_event, instance)
  #     return unless (methods = callbacks[lifecycle_event])

  #     methods.each do |callback_method|
  #       instance.output.puts "-> [#{lifecycle_event}] Running '#{callback_method}'" if instance.options.debug > 1
  #       instance.send(callback_method)
  #     end
  #   end
  # end

  # def with_callbacks
  #   self.class.run_callbacks(:before_validate, self)
  #   self.class.run_callbacks(:on_validate, self)
  #   self.class.run_callbacks(:aftere_validate, self)
  #   self.class.run_callbacks(:before_execute, self)
  #   self.class.run_callbacks(:on_execute, self)
  #   yield
  #   self.class.run_callbacks(:after_execute, self)
  #   self.class.run_callbacks(:before_finalize, self)
  #   self.class.run_callbacks(:on_finalize, self)
  #   self.class.run_callbacks(:after_finalize, self)
  # end
end
