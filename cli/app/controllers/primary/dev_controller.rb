# frozen_string_literal: true

# An application consists of multiple services each of which may have their own:
# - container registry
# - git repo
# - image tag calculation/format
# - version
# - image prefix

# each service can have a repo
# service can be a path within the repo
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
  class DevController < ApplicationController
    def execute
      Repository::Git.all.each do |repo|
        next if Dir.exist?(repo.full_path)

        response.add(exec: repo.pull)
      end
    end
  end
end
