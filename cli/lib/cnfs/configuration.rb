# frozen_string_literal: true

module Cnfs
  class Configuration
    def self.initialize!
      # Set up in-memory database
      # https://stackoverflow.com/questions/58649529/how-to-create-multiple-memory-databases-in-sqlite3
      # "file:memdb1?mode=memory&cache=shared"
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      Cnfs.with_timer('initialize') { initialize }
      Builder::Ansible.clone_repo
    end

    def self.reload
      # Remove any A/R Cached Classes (e.g. STI classes)
      ActiveSupport::Dependencies::Reference.clear!
      # Re-seed fixtures
      ActiveRecord::FixtureSet.reset_cache
      Cnfs.with_timer('reload') { initialize }
    end

    def self.initialize
      setup_database_tables
      load_configuration
    end

    def self.setup_database_tables
      Cnfs.silence_output do
        ActiveRecord::Schema.define do |s|
          Cnfs::Configuration.models.each do |model|
            model.create_table(s)
            model.reset_column_information
          end
        end
      end
    end

    # rubocop:disable Metrics/AbcSize
    # Convert configruation into fixtures and load them into the DB
    def self.load_configuration
      dir.rmtree if dir.exist?
      dir.mkpath
      models.each(&:parse)
      fixtures = Dir.chdir(dir) { Dir['**/*.yml'] }.map { |f| f.gsub('.yml', '') }.sort
      ActiveRecord::FixtureSet.create_fixtures(dir, fixtures)
      models.each(&:after_parse)
      Cnfs.project = Project.first
      Cnfs.invoke_plugins_with(:on_project_initialize)
    ensure
      FileUtils.rm_rf(dir) unless Cnfs.config.retain # _artifacts
    end
    # rubocop:enable Metrics/AbcSize

    # rubo_cop:disable Naming/RescuedExceptionsVariableName
    # rubo_cop:disable Metrics/MethodLength
    # def self.load_fixtures
    #   fixtures = Dir.chdir(dir) { Dir['**/*.yml'] }.map { |f| f.gsub('.yml', '') }.sort
    #   ActiveRecord::FixtureSet.create_fixtures(dir, fixtures)
    # rescue Psych::BadAlias => a
    #   failing_fixture = nil
    #   begin
    #     fixtures.each do |fixture|
    #       failing_fixture = fixture
    #       ActiveRecord::FixtureSet.create_fixtures(dir, fixture)
    #     end
    #   rescue Psych::BadAlias => b
    #     fixture_contents = File.read(dir.join("#{failing_fixture}.yml"))
    #     c = StandardError.new "Error parsing configuration in #{failing_fixture}.yml\n#{fixture_contents}"
    #     [a, b, c].map { |exception| exception.set_backtrace([]) }
    #     raise c
    #   end
    # ensure
    #   FileUtils.rm_rf(dir) unless Cnfs.config.retain # _artifacts
    #   Cnfs.project = Project.first
    #   Cnfs.invoke_plugins_with(:on_project_initialize)
    # end
    # rubo_cop:enable Naming/RescuedExceptionsVariableName
    # rubo_cop:enable Metrics/MethodLength

    def self.models
      [Blueprint, Builder, Dependency, Environment, Location, Namespace, Project,
       Provider, Registry, Repository, Resource, Runtime, Service, User]
    end

    def self.dir
      Cnfs.paths.tmp.join('fixtures')
    end
  end
end
