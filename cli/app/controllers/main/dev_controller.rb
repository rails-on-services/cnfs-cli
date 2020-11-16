# frozen_string_literal: true

# A project consists of multiple environments each with multiple namespaces
# services run in teh context of a namespace. Each service may have its own:
# - container registry
# - git repo
# - image tag calculation/format
# - version
# - image prefix
# - etc

module Main
  class DevController < ApplicationController
    def execute
      binding.pry
    end

    def git_test
      Repository::Git.all.each do |repo|
        next if Dir.exist?(repo.full_path)

        response.add(exec: repo.pull)
      end
    end
  end
end
