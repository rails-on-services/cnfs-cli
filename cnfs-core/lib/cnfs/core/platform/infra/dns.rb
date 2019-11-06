# frozen_string_literal: true

module Cnfs::Core
  class Platform::Infra::Dns
    include Concerns::Resource

    def hostv(host)
      OpenStruct.new(
        scheme: settings.endpoints.send(host)&.scheme || 'https',
        name: settings.endpoints.send(host)&.host || host, 
        feature_set: settings.endpoints.send(host)&.feature_set || 'host'
      )
    end

    def uri(host)
      URI("#{hostv(host).scheme}://#{hostname(host)}").to_s
    end

    def hostname(host)
      "#{base_host(host)}.#{domain}"
    end

    def base_host(host)
      return host unless (fs = component.partition.platform.feature_set) and hostv(host).feature_set.eql?('host')
      [hostv(host).name, fs].compact.join('-')
    end

    def domain_slug
      @domain_slug ||= "#{domain.gsub('.', '-')}"
    end

    def domain
      @domain ||= [settings.sub_domain, settings.root_domain].compact.join('.')
    end
  end
end
