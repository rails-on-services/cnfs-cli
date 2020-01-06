# frozen_string_literal: true

module Primary
  class CopyController < ApplicationController

    def execute
      each_target do
        execute_on_target
      end
    end

    def execute_on_target
      src = args.src
      dest = args.dest
      src_service = src.include?(':')
      dest_service = dest.include?(':')
      raise ArgumentError.new('only one of source or destination can be a service') if src_service and dest_service
      raise ArgumentError.new('one of source or destination must be a service') unless src_service or dest_service

      runtime.copy(src, dest)
      run!
    end
  end
end
