# frozen_string_literal: true

module Services
  class StopController < ApplicationController
    def execute
      application.stop
    end
  end
end
