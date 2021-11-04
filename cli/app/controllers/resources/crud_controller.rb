# frozen_string_literal: true

module Resources
  class CrudController
    include ResourcesHelper

    def create
      res = Resource.new.create
      binding.pry
      res.save
    end

    def delete
      binding.pry
      # run_in_path(:destroy) do |result|
      #   raise Cnfs::Error, result.err if result.failure?
      # end
    end

    # Empty method b/c it is handled by InfraHelper#before_execute
    def execute
      # infra_runtime.generate
    end
  end
end
