# frozen_string_literal: true

module Cnfs
  class Configuration
    def self.initialize!
      # Set up in-memory database
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      initialize
    end

    def self.reload
      # Enable fixtures to be re-seeded on code reload
      ActiveRecord::FixtureSet.reset_cache
      initialize
    end

    private

    def self.initialize
      dir.mkpath
      models.each { |model| model.parse }
      Cnfs.silence_output { create_schema }
      load_fixtures
    end

    def self.models
      [Blueprint, Builder, Dependency, Environment, Key, Namespace, Project,
       Provider, Registry, Repository, Runtime, Service, User]
    end

    # Set up database tables and columns
    def self.create_schema
      ActiveRecord::Schema.define do
        # create_table :assets, force: true do |t|
        #   t.string :name
        #   t.string :type
        #   t.string :path
        #   t.string :owner_type
        #   t.string :owner_id
        #   t.string :tags
        # end
        # Asset.reset_column_information

        create_table :blueprints, force: true do |t|
          t.references :environment
          t.string :config
          t.string :environment
          t.string :name
          t.string :source
          t.string :tags
          t.string :type
          t.string :version
        end
        Blueprint.reset_column_information

        create_table :builders, force: true do |t|
          t.references :project
          t.string :config
          t.string :environment
          t.string :name
          t.string :tags
          t.string :type
        end
        Builder.reset_column_information

        create_table :dependencies, force: true do |t|
          t.references :project
          t.string :name
          t.string :linux
          t.string :mac
          t.string :tags
        end
        Key.reset_column_information

        create_table :environments, force: true do |t|
          t.references :builder
          t.references :blueprint
          t.references :key
          t.references :project
          t.references :provider
          t.references :runtime
          t.string :name
          t.string :config
          t.string :environment
          t.string :tags
          t.string :tf_config
          t.string :type
          # t.string :dns_root_domain
        end
        Environment.reset_column_information

        create_table :keys, force: true do |t|
          t.string :name
          t.string :tags
          t.string :value
        end
        Key.reset_column_information

        create_table :namespaces, force: true do |t|
          t.references :environment
          t.references :key
          t.string :config
          t.string :environment
          t.string :name
          t.string :tags
        end
        Namespace.reset_column_information

        create_table :projects, force: true do |t|
          t.references :environment
          t.references :namespace
          t.references :repository
          t.references :source_repository
          t.string :name
          t.string :config
          t.string :options
          t.string :paths
          t.string :tags
        end
        Project.reset_column_information

        create_table :providers, force: true do |t|
          t.references :project
          t.string :config
          t.string :environment
          t.string :name
          t.string :tags
          t.string :type
          # t.string :kubernetes
        end
        Provider.reset_column_information

        create_table :registries, force: true do |t|
          t.string :name
          t.string :config
          t.string :type
        end
        Registry.reset_column_information

        create_table :repositories, force: true do |t|
          t.references :project
          t.string :config
          t.string :name
          t.string :namespace
          t.string :path
          t.string :service_type
          t.string :test_framework
          t.string :type
          t.string :tags
        end
        Repository.reset_column_information

        create_table :runtimes, force: true do |t|
          t.references :project
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
          t.string :tags
        end
        Runtime.reset_column_information

        # create_table :resources, force: true do |t|
        #   t.string :name
        #   t.string :config
        #   t.string :environment
        #   t.string :resources
        #   t.string :type
        #   t.string :template
        # end
        # Resource.reset_column_information

        create_table :services, force: true do |t|
          t.references :namespace
          # TODO: Perhaps these are better as strings that can be inherited
          # t.references :source_repo
          # t.references :image_repo
          # t.references :chart_repo
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
          t.string :template
          t.string :path
          t.string :profiles
          t.string :tags
        end
        Service.reset_column_information

        create_table :users, force: true do |t|
          t.references :project
          t.string :name
          t.string :role
          t.string :tags
        end
        User.reset_column_information
      end
    end

    def self.load_fixtures
      fixtures = Dir.chdir(dir) { Dir['**/*.yml'] }.map { |f| f.gsub('.yml', '') }.sort
      ActiveRecord::FixtureSet.create_fixtures(dir, fixtures)
    # rescue ActiveRecord::Fixture::FixtureError => err
    #   raise Cnfs::Error, err
    rescue Psych::BadAlias => a
      failing_fixture = nil
      begin
        fixtures.each do |fixture|
          failing_fixture = fixture
          ActiveRecord::FixtureSet.create_fixtures(dir, fixture)
        end
      rescue Psych::BadAlias => b
        fixture_contents = File.read(dir.join("#{failing_fixture}.yml"))
        c = StandardError.new "Error parsing configuration in #{failing_fixture}.yml\n#{fixture_contents}"
        [a, b, c].map { |exception| exception.set_backtrace([]) }
        raise c
      end
    ensure
      FileUtils.rm_rf(dir) unless Cnfs.config.retain #_artifacts
      Cnfs.project = Project.first
      Cnfs.invoke_plugins_with(:on_project_initialize)
    end
    # rubocop:enable Metrics/MethodLength

    def self.dir
      Cnfs.paths.tmp.join('fixtures')
    end
  end
end
