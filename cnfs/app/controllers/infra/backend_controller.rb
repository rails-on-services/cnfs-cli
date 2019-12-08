# frozen_string_literal: true

module Infra
  class BackendController < Thor
    # namespace 'application backend' #:backend

    desc 'deploy', 'Deploy backend application to target infrastructure'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    def deploy(name)
      # Cnfs::Commands::Infra::Backend::Deploy.new(name, options).execute
    end
  end
end
