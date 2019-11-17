# frozen_string_literal: true

module Cnfs::Commands::Application
  module Backend::Status::Compose

    def self.included(base)
      base.include Cnfs::Commands::Compose
      base.on_execute :run_compose
    end

    def run_compose
      # binding.pry
      @result = { platform: [], core: [], infra: [] }
      config.platform.application.backend.rails.settings.units.keys.sort.each do |svc_name|
        svc = config.platform.application.backend.rails.settings.units.dig(svc_name)
        part = svc.dig(:ros) ? :core : :platform
        (svc.profiles || %w[server]).each do |profile|
          name = profile.eql?('server') ? svc_name : "#{svc_name}_#{profile}"
          status = get_status(name, svc)
          result[part].append([name, status])
        end
      end
      # (application.components.services.components.keys - %i(wait)).sort.each do |name|
      #   svc = application.components.services.components[name.to_s]
      #   status = get_status(name, svc)
      #   infra_services[name] = status
      # end
      max = [result[:core].size, result[:platform].size, result[:infra].size].max
      @result = Array.new(max) do
        (result[:platform].shift || [nil, nil]) + (result[:core].shift || [nil, nil]) + (result[:infra].shift || [nil, nil])
      end
    end

    def get_status(name, svc)
      return 'Running' if services.include?(name.to_s)
      svc.disabled ? 'Not Enabled' : 'Stopped'
    end
  end
end
