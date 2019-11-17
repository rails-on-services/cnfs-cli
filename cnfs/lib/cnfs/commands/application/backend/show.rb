# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Show < Cnfs::Command
    on_execute :show_results

    def show_results
      output.puts(File.read(show_file))
      output.puts("\nContents from: #{show_file}")
    end

    def show_file
      platform.path_for.join('application/backend').join("#{args[:service]}/#{args[:service]}.yml").to_s
    end
  end
end
