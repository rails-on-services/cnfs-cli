# frozen_string_literal: true

module Services
  class BuildController < ApplicationController
    def execute
      application.build
    end
  end
end
