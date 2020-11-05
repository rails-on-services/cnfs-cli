# frozen_string_literal: true

module Primary
  class AttachController < ApplicationController
    def execute(entry)
      super
      run(:build) if options.build
      runtime.attach.run!
    end
  end
end
