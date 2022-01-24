# frozen_string_literal: true

module OneStack::Concerns
  module Download
    extend ActiveSupport::Concern

    included do
      include OneStack::Concerns::Git
    end

    def download(url:, path:, spinner: false)
      require 'tty-file'
      require 'tty-spinner' if spinner

      url = Pathname.new(url)
      path = Pathname.new(path)
      path.mkpath unless path.exist?

      Dir.chdir(path) do
        file = url.basename
        if file.exist? # && !options.clean
          FileUtils.rm(file)
          Hendrix.logger.warn("#{file} exists")
          # Cnfs.logger.info "Dependency #{dependency[:name]} exists locally. To overwrite run command with --clean flag."
          # next
        end
        do_it(url, file, spinner)
      end
    end

    def do_it(url, file, spinner)
      if spinner
        spinner(file).run { |_spinner| more(url, file) }
      else
        more(url, file)
      end
    end

    def more(url, _file)
      if git_url?(url.to_s)
        git_clone(url.to_s).run
      else
        TTY::File.download_file(url.to_s)
      end
    end

    # rubocop:disable Naming/VariableNumber
    def spinner(file)= TTY::Spinner.new("[:spinner] Downloading #{file}...", format: :pulse_2)
    # rubocop:enable Naming/VariableNumber
  end
end
