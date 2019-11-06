# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Test < Cnfs::Command
    attr_accessor :services, :options, :result

    after_execute :show_results

    def initialize(services, options)
      @services = services
      @options = options
      type = :compose
      self.class.include(self.class.registrations[type]) if self.class.registrations[type]
    end

    def show_results
      if errors.size.positive?
        output.puts(errors.messages.map{ |(k, v)| "#{v}\n" })
        Kernel.exit(errors.size)
      end
    end
  end
end
