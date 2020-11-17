# frozen_string_literal: true

# Create a new service from a gem (angular, rails) into a repository
# To hook into this controller gems need to implement <Namespace>::Services::NewController
module Services
  class NewController < Thor
    include Cnfs::Options

    # Activate common options
    cnfs_class_options :repository, :noop, :quiet, :verbose

    private
  end
end
