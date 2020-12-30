# frozen_string_literal: true

module Main
  class BuildController
    include ExecHelper

    # rubocop:disable Metrics/AbcSize
    def execute
      return unless (build = Build.find_by(name: args.name))

      build.execute_path.mkpath unless build.execute_path.exist?
      Dir.chdir(build.execute_path) do
        BuildGenerator.new([build], options).invoke_all
        build.render
        # binding.pry

        command.run!({ 'PACKER_CACHE_DIR' => Cnfs.project.cache_path.to_s },
                     "packer build --force #{build.packer_file}")
      end
      # command.run!('ansible --version')
    end
    # rubocop:enable Metrics/AbcSize

    def command
      TTY::Command.new(**options)
    end
  end
end
