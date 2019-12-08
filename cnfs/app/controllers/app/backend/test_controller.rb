# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Test < Cnfs::Command
    before_execute :generate_manifests
    after_execute :show_results

    def show_results
      binding.pry
      if errors.size.positive?
        output.puts(errors.messages.map{ |(k, v)| "#{v}\n" })
        Kernel.exit(errors.size)
      end
    end
  end
end
