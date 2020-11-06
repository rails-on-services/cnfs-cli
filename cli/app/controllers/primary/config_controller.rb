# frozen_string_literal: true

module Primary
  class ConfigController < Thor
    register Config::SetController, 'set', 'set [SUBCOMMAND]', 'set a configuration value'

    desc 'get NAME', 'get a configuration value'
    option :local, desc: 'Manage local configuration',
      aliases: '-l', type: :boolean
    def get(name = nil)
      YAML.load_file('cnfs.yml').each do |key, value|
        puts "#{key}: #{value}"
      end
    end
  end
end
