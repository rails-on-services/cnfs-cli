# frozen_string_literal: true

module Main
  class BuildController
    include ExecHelper

    def execute
      BuildGenerator.new([args.name], options).invoke_all
      command.run!('ansible --version')
      binding.pry
      # path = Pathname.new(args.name).join('config')
      # path.mkpath
      # FileUtils.cp(CnfsPacker.gem_root.join('config/project.yml'), path.join('project.yml'))
    end

    def command
      TTY::Command.new
    end
  end
end
