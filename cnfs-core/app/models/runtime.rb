# frozen_string_literal: true

class Runtime < ApplicationRecord
  has_many :targets

  store :config, accessors: %i[version], coder: YAML

  # Attributes configured by the controller
  attr_accessor :controller, :target

  # Sub-classes, e.g. compose, skaffold can override to implement, e.g. switch!
  def before_execute_on_target; end

  def clean_cache(request)
    if request.services.empty?
      FileUtils.rm_rf(runtime_path)
      return
    end
    request.services.each do |service|
      migration_file = "#{runtime_path}/#{service.name}-migrated"
      FileUtils.rm(migration_file) if File.exist?(migration_file)
      FileUtils.rm(credentials[:local_file]) if service.name.eql?('iam') and File.exist?(credentials[:local_file])
    end
  end

  def credentials
    { remote_file: "/home/rails/services/app/tmp/#{'mounted'}/credentials.json",
      local_file: "#{runtime_path}/target/credentials.json",
      local_path: "#{runtime_path}/target" }
  end

  def runtime_path; @runtime_path ||= target.write_path(:runtime) end

  def project_name; "#{target.application.name}_#{target.name}" end

  # run command with output captured to variables
  # returns boolean true if command successful, false otherwise
  def capture_cmd(cmd, envs = {})
    return if setup_cmd(cmd)
    @stdout, @stderr, process_status = Open3.capture3(envs, cmd)
    @exit_code = process_status.exitstatus
    @exit_code.zero?
  end

  # run command with output captured unless verbose (options.v) then to terminal
  # returns boolean true if command successful, false otherwise
  def system_cmd(cmd, envs = {}, never_capture = false)
    return capture_cmd(cmd, envs) unless (options.v or never_capture)
    return if setup_cmd(cmd)
    system(envs, cmd)
    @exit_code = $?.exitstatus
    @exit_code.zero?
  end

  def setup_cmd(cmd)
    puts cmd if options.v
    @stdout = nil
    @stderr = nil
    @exit_code = 0
    options.n
  end

  def exit
    STDOUT.puts(errors.messages.map{ |(k, v)| "#{v}\n" }) if errors.size.positive?
    Kernel.exit(errors.size)
  end
end
