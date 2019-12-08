# frozen_string_literal: true

module Cnfs
  module Commands
    module Infra
      class Backend < Thor
        # namespace 'application backend' #:backend

        desc 'deploy', 'Deploy backend application to target infrastructure'
        method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
        option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
        def deploy(name)
          if options[:help]
            invoke :help, ['deploy']
          else
            require_relative 'backend/deploy'
            Cnfs::Commands::Infra::Backend::Deploy.new(name, options).execute
          end
        end
      end
    end
  end
end
