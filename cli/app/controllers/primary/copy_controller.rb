# frozen_string_literal: true

module Primary
  class CopyController < ApplicationController
    def execute
      each_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      src = args.src
      dest = args.dest
      src_service = src.include?(':')
      dest_service = dest.include?(':')
      raise ArgumentError, 'only one of source or destination can be a service' if src_service && dest_service
      raise ArgumentError, 'one of source or destination must be a service' unless src_service || dest_service

      runtime.copy(src, dest)
      response.run!
    end
  end
end
