# frozen_string_literal: true

module Primary
  class RestartController < ApplicationController
    def execute
      application.restart
    end
  end
end
