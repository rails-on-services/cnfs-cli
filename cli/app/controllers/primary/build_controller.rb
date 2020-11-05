# frozen_string_literal: true

module Primary
  class BuildController < ApplicationController
    def execute
      application.build
    end
  end
end
