# frozen_string_literal: true

module Images
  class BuildController
    include ExecHelper

    def execute
      puts "building #{args.services.join(' ')}"
    end
  end
end
