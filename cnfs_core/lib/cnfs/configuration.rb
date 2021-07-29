# frozen_string_literal: true

module Cnfs
  class Configuration
    class << self
      attr_accessor :models
    end

    def self.initialize!
      # Set up in-memory database
      # https://stackoverflow.com/questions/58649529/how-to-create-multiple-memory-databases-in-sqlite3
      # "file:memdb1?mode=memory&cache=shared"
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      Cnfs.with_timer('initialize') { initialize }
    end

    def self.reload
      # Remove any A/R Cached Classes (e.g. STI classes)
      ActiveSupport::Dependencies::Reference.clear!
      # Re-seed fixtures
      ActiveRecord::FixtureSet.reset_cache
      Cnfs.with_timer('reload') { initialize }
    end

    def self.initialize
      ActiveSupport::Notifications.instrument('before_project_configuration.cnfs')
      create_database_tables
      load_project_config_into_tables
      ActiveSupport::Notifications.instrument('after_project_configuration.cnfs')
    end

    def self.create_database_tables
      Cnfs.silence_output do
        ActiveRecord::Schema.define do |s|
          Cnfs::Configuration.models.each do |model|
            model.create_table(s)
            model.reset_column_information
          end
        end
      end
    end

    # Convert configruation into fixtures and load them into the DB
    # rubocop:disable Metrics/AbcSize
    def self.load_project_config_into_tables
      fixtures_dir.rmtree if fixtures_dir.exist?
      fixtures_dir.mkpath
      # What and how configurations are parsed is project specific so this should be a callback to the gem's code to implememt parse
      Cnfs.prepare_fixtures(models)
      # models.each(&:parse)
      fixtures = Dir.chdir(fixtures_dir) { Dir['**/*.yml'] }.map { |f| f.gsub('.yml', '') }.sort
      ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, fixtures)
      models.each(&:after_parse)
      # TODO: This has to be moved to CLI gem
      Cnfs.project = Project.first
    ensure
      FileUtils.rm_rf(fixtures_dir) unless Cnfs.config.retain # _artifacts
    end
    # rubocop:enable Metrics/AbcSize

    def self.fixtures_dir
      @dir ||= Cnfs.paths.tmp.join('fixtures')
    end

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
    # end
    # rubo_cop:enable Naming/RescuedExceptionsVariableName
    # rubo_cop:enable Metrics/MethodLength
  end
end
