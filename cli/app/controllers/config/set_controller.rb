# frozen_string_literal: true

module Config
  class SetController < Thor

    class_option :local, desc: 'Manage local configuration',
      aliases: '-l', type: :boolean

    desc 'environment VALUE', 'set default environment'
    def environment(value)
      config_set(:environment, value)
    end

    desc 'namespace VALUE', 'set default namespace'
    def namespace(value)
      config_set(:namespace, value)
    end

    desc 'repository VALUE', 'set default repository'
    def repository(value)
      config_set(:repository, value)
    end

    private

    def config_set(name, value)
      o = Config.load_file('cnfs.yml')
      # TODO: Decide what config goes where
      # user_root cnfs.yml should have things like cli.dev
      # but user_root.join(project_name, cnfs.yml) should override the project values
      # Which values are in Cnfs adn which are in Cnfs.project
      # TODO: This is confusing atm
      if options.local
        # o = Cnfs.user_root.join(name, 'cnfs.yml')
      end
      o[name] = value
      o.save
    end
  end
end
