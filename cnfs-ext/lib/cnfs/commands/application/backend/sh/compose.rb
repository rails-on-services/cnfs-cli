# frozen_string_literal: true

module Cnfs::Commands::Application
  module Backend::Sh::Compose

    def self.included(base)
      base.include Cnfs::Commands::Compose
      base.on_execute :run_compose
    end

    def run_compose
      compose(args.service, 'bash')
    end
  end
end
