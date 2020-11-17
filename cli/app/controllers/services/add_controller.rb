# frozen_string_literal: true

# Add a service configuration from a repository to the project configuration
#   at the requested scope: project, environment or namespace
# To hook into this controller repositories need to implement <Namespace>::Services::AddController
module Services
  class AddController < Thor
    include Cnfs::Options

    # Activate common options
    cnfs_class_options :noop, :quiet, :verbose
    # class_option :environment, desc: 'Target environment',
    #                            aliases: '-e', type: :string
    # class_option :namespace, desc: 'Target namespace',
    #                          aliases: '-n', type: :string
  end
end