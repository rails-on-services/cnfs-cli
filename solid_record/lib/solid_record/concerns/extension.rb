# frozen_string_literal: true

module SolidRecord
  def self.gem_root = @gem_root ||= Pathname.new(__dir__).join('../..')

  class Extension < SolidSupport::Extension
    # The config object belongs to the application so it is 'shared' with the app and other Extensions
    # config.before_configuration do
    #   binding.pry
    #   puts 'SolidRecord before_configuration'
    # end

    # config.before_initialize { |config| SolidRecord.config.merge!(config.solid_record || {}) }
    config.before_initialize do |config|
      binding.pry
      SolidRecord.config.merge!(config.solid_record || {})
    end

    # config.before_eager_load do |config|
    #   puts 'SolidRecord before_eager_load'
    # end

    # After all extensions have been required
    config.after_initialize do |config|
      # SolidRecord::DataStore.load(*config.solid_record.load_paths)
      # SolidRecord.tables.select { |t| t.respond_to?(:after_load) }.each(&:after_load)
    end

    def self.gem_root = SolidRecord.gem_root
  end
end
