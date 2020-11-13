# frozen_string_literal: true

module Images
  class BuildController < ApplicationController
    def execute
      application.build
    end
  end
end
