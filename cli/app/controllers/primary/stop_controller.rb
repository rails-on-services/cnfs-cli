# frozen_string_literal: true

module Primary
  class StopController < ApplicationController
    def execute
      application.stop
    end
  end
end
