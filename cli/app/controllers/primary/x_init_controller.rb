# frozen_string_literal: true

# An application consists of multiple services each of which may have their own:
# - container registry
# - git repo
# - image tag calculation/format
# - version
# - image prefix

# Application has a repo, each service can have a repo
# Application or service can be a path within the repo
# The path on the application and service is where it is on the file system relative to the project
# Override the application and service path with local config
# if application path is not defined then use .
# if app path starts with ~ then call expand_path otherwise just pathname
# if pathname is not relative then return path
# otherwise all pathnames start with 'apps/'
# if application path is not defined and app.sourcE_repo is defined then apps/[repo.name + repo.path].compact

# if application path is not defined then apps/name
# clone the source to source repo in teh application_path or '.'

module Primary
  class XInitController < ApplicationController
    def execute
      return unless (app = Application.find_by(name: args.application_name))

      app.source_repos.uniq.each do |repo|
        command.run!(repo.clone_cmd) unless Dir.exist?(repo.full_path)
      end
    end
  end
end
