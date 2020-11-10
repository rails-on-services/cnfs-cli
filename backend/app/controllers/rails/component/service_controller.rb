# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
module Rails
  module Component
    class ServiceController < Thor

      desc 'xiam', 'Add the IAM service'
      def xiam(name = 'iam')
        binding.pry
      end
    end
  end
end
