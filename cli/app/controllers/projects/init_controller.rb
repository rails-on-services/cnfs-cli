# frozen_string_literal: true

module Projects
  class InitController < ApplicationController
    def execute
      Repository.all.each do |repo|
        response.add(exec: repo.pull) if repo.valid? && repo.pull
      end
    end
  end
end
