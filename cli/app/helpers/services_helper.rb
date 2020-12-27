# frozen_string_literal: true

module ServicesHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper
    include TtyHelper
  end

  def before_execute
    project.process_manifests
    if respond_to?(:service)
      unless (self.service = project.services.find_by(name: args.service))
        raise Cnfs::Error, "Service not found #{args.service}"
      end
    elsif respond_to?(:services)
      where_params = {}
      where_params.merge!(name: args.services) unless args.services.empty?
      # TODO: Modify to take tags and profiles
      # where_params.merge!(options.tags) if options.tags
      self.services = where_params.empty? ? project.services : project.services.where(where_params)
      unless services.any?
        raise Cnfs::Error, "No services selected. Filtered by: #{where_params.map { |k, v| "#{k} = #{v}" }.join(', ')}"
      end
    end
  end
end
