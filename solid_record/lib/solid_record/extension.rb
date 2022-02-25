# frozen_string_literal: true

module SolidRecord
  def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')

  class Extension < Hendrix::Extension
    # Access this config from the app with SolidRecord::Extension.config
    config.active_record = ActiveSupport::OrderedOptions.new
    config.flush_cache = true

    config.before_configuration do
      puts 'SolidRecord before_configuration'
    end

    config.before_initialize do |config|
      config.solid_record.data_paths ||= []
      # binding.pry
      puts 'SolidRecord before_initialize'
    end

    config.before_eager_load do |config|
      # This config object belongs to the application so it is 'shared' with the app and other Lyrics
      # binding.pry
      config.solid_record.message = 'from solid record initializer data'
      puts 'SolidRecord before_eager_load'
    end

    # After all extensions have been required
    config.after_initialize do |config|
      SolidRecord::DataStore.load
      config.solid_record.data_paths.each do |data_path|
        data_path = SolidRecord::DataPath.create(**data_path)
        SolidSupport.logger.debug(data_path)
      end
      SolidRecord.tables.select { |t| t.respond_to?(:after_load) }.each(&:after_load)
    end

    def self.gem_root() = SolidRecord.gem_root
  end
end
