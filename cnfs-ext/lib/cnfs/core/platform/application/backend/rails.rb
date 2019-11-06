# frozen_string_literal: true

module Cnfs::Core
  class Platform::Application::Backend::Rails
    include Concerns::Resource

    def generate
      generate_platform_env
      generate_services
      nil
    end

    def generate_platform_env
      g = "#{generator_base}::PlatformEnv".constantize.new
      g.values = self
      g.invoke_all
    end

    def generate_services
      settings.units.each_pair do |key, values|
        next unless values.disabled
        g = "#{generator_base}::Service".constantize.new([], { values: self, service: key, config: values })
        g.invoke_all
      end
    end

    def generator_base; self.class.name.gsub('Platform', 'Generator') end

    # NOTE: image_prefix is specific to the image_type
    def image_prefix; config.dig(:image, :build_args, :rails_env) end
  end
end
