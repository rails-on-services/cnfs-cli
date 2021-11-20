# frozen_string_literal: true

module Concerns
  module HasEnvs
    extend ActiveSupport::Concern

    included do
      table_mod :envs_add_column

      store :envs, coder: YAML

      after_initialize :do_it, if: proc { persisted? }
    end

    def do_it
      envs.keys.each do |key|
        define_singleton_method(key.to_sym) { values[key] }
        define_singleton_method("#{key}=".to_sym) { |name| values[key] = name }
      end
    end


    def cnfs_sub
      # "https://api.${project.environment.domain}"
      platform['jwt']['aud']
    end

    def yeah
      self.secret_key_base = encrypt(SecureRandom.hex(64))
      self.rails_master_key = encrypt(SecureRandom.hex)
      envs['platform']['jwt']['encryption_key'] = encrypt(SecureRandom.hex)
      nil
    end

    def show
      puts as_json.to_yaml
    end

    class_methods do
      def envs_add_column(t)
        t.string :envs
      end
    end
  end
end

# store :config, accessors: %i[domain], coder: YAML
# store :config, accessors: %i[dns_sub_domain mount root_domain_managed_in_route53 lb_dns_hostnames], coder: YAML

# TODO: Maybe this goes into a concern that can be included in component or other
# def domain_slug
#   @domain_slug ||= domain_name.gsub('.', '-')
# end

# def domain_name
#   @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
# end
