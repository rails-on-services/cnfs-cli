# frozen_string_literal: true

module SolidView
  def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')

  class Extension < SolidSupport::Extension
    # The config object belongs to the application so it is 'shared' with the app and other Extensions
    # config.before_configuration do
    #   puts 'SolidView before_configuration'
    # end

    config.before_initialize { |config| SolidView.config.merge!(config.solid_view) }

    # config.before_eager_load do |config|
    #   puts 'SolidView before_eager_load'
    # end

    # After all extensions have been required
    config.after_initialize do |config|
    end

    def self.gem_root() = SolidView.gem_root
  end
end
