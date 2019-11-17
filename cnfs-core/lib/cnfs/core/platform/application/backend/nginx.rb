# frozen_string_literal: true

module Cnfs::Core
  class Platform::Application::Backend::Nginx
    include Concerns::Resource

    def services
      parent.resources.each_with_object([]) do |resource, ary|
        ary.append(resource.settings.dig(:units)&.keys || [])
      end.flatten
    end
  end
end
