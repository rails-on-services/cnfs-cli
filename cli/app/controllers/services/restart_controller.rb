# frozen_string_literal: true

module Services
  class RestartController < ApplicationController
    def execute
      application.restart
    end
  end
end
