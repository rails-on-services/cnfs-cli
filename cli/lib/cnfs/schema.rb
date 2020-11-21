# frozen_string_literal: true

module Cnfs
  class Schema
    cattr_accessor :dir

    def self.initialize!
      # Set up in-memory database
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      prepare
      parse
      import
    end

    def self.prepare
      show_output = Cnfs.config.debug.positive?
      Cnfs.silence_output(!show_output) { create_schema }
    end

    def self.parse
      dir.mkpath
      models.each { |model| model.parse }
    end

    def self.reload
      # Enable fixtures to be re-seeded on code reload
      ActiveRecord::FixtureSet.reset_cache
      prepare
      import
    end

    # rubocop:disable Metrics/MethodLength
    def self.import
      fixtures = Dir.chdir(dir) { Dir['**/*.yml'] }.map { |f| f.gsub('.yml', '') }.sort
      # binding.pry
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
      # TODO: Maybe this should be a setting to disable auto remove for debugging purposes
      # FileUtils.rm_rf(dir)
    end

    def self.models
      [Project, Environment, Key, Namespace, Provider, Repository, Runtime, Service, User]
    end

    # Set up database tables and columns
    def self.create_schema
      ActiveRecord::Schema.define do
        create_table :projects, force: true do |t|
          t.references :repository
          t.references :source_repository
          t.references :environment
          t.references :namespace
          t.string :name
          t.string :config
          t.string :paths
          t.string :options
          t.string :tags
        end
        Project.reset_column_information

        create_table :assets, force: true do |t|
          t.string :name
          t.string :type
          t.string :path
          t.string :owner_type
          t.string :owner_id
        end
        Asset.reset_column_information

        create_table :blueprints, force: true do |t|
          t.string :name
          t.string :type
          t.string :source
          t.string :version
          t.string :config
          t.string :environment
        end
        Blueprint.reset_column_information

        create_table :environments, force: true do |t|
          t.references :project
          t.references :key
          t.references :runtime
          t.references :infra_runtime
          t.references :provider
          t.references :blueprint
          t.string :name
          t.string :config
          t.string :tf_config
          t.string :environment
          t.string :type
          t.string :dns_root_domain
          t.string :tags
        end
        Environment.reset_column_information

        create_table :keys, force: true do |t|
          t.string :name
          t.string :value
          t.string :tags
        end
        Key.reset_column_information

        create_table :namespaces, force: true do |t|
          t.references :environment
          t.references :key
          t.string :name
          t.string :config
          t.string :environment
          t.string :tags
        end
        Namespace.reset_column_information

        create_table :providers, force: true do |t|
          t.references :project
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
          t.string :tags
          # t.string :kubernetes
        end
        Provider.reset_column_information

        # create_table :registries, force: true do |t|
        #   t.string :name
        #   t.string :config
        #   t.string :type
        # end
        # Registry.reset_column_information

        create_table :repositories, force: true do |t|
          t.references :project
          t.string :name
          t.string :config
          t.string :type
          t.string :service_type
          t.string :path
          t.string :namespace
          t.string :test_framework
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
    # rubocop:enable Metrics/MethodLength

    def self.dir
      Cnfs.paths.tmp.join('dump')
    end
  end
end
