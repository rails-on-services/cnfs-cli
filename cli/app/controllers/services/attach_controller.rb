# frozen_string_literal: true

module Services
  class AttachController < ApplicationController
    def execute(entry)
      super
      run(:build) if options.build
      runtime.attach.run!
    end
  end
end
