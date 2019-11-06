# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Status < Cnfs::Command
    module Compose

      def self.included(base)
        base.on_execute :run_compose
      end

      # TODO: Move to common concern
      def running_services
        @running_services ||= Cnfs::Commands::Application::Backend::Ps.new(options).execute.result
      end

      def run_compose
        # switch!
        @result = { platform: [], core: [], infra: [] }
        Cnfs.platform.application.backend.rails.settings.units.keys.sort.each do |svc_name|
          svc = Cnfs.platform.application.backend.rails.settings.units.dig(svc_name)
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
        return 'Running' if running_services.include?(name.to_s)
        svc.disabled ? 'Not Enabled' : 'Stopped'
      end
    end
  end
end
