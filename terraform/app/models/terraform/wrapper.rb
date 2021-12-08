# frozen_string_literal: true

module Terraform
  class Wrapper
    include ActiveModel::Model

    attr_writer :path

    def resources_where(**kwargs)
      select_string = kwargs.each_with_object([]) { |(k, v), ary| ary.append "res['#{k}'].eql?('#{v}')" }.join(' && ')
      resources.select { |res| eval(select_string) }
    end

    def resources() = @resources ||= show_hash['values']['root_module']['resources']

    def show_hash() = JSON.parse(show).with_indifferent_access 

    def show() = rt_exec(:show)

    def rt_exec(cmd)
      io = StringIO.new
      rt_class(cmd).new(stdout: io).execute(rt_options)
      io.string
    end

    def rt_class(cmd) = "ruby_terraform/commands/#{cmd}".classify.constantize

    def rt_options() = { chdir: @path.to_s, json: true }

    # def resources() = @resources ||= j_state['values']['root_module']['resources']

    # def j_state() = @j_state ||= JSON.parse(state).with_indifferent_access 

    # def state() = @state ||= Dir.chdir(@path) { `terraform show --json` }

    # def state() = File.read(path)

    # def path() = Pathname.new(@path).join('terraform.tfstate')
  end
end
