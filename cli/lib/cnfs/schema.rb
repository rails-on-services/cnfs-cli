# frozen_string_literal: true

module Cnfs
  class Schema
    def self.setup
      # Set up in-memory database
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable %w[dns kubernetes postgres redis rails]
      end
      load_data
    end

    def self.reload
      # Enable fixtures to be re-seeded on code reload
      ActiveRecord::FixtureSet.reset_cache
      load_data
    end

    def self.load_data
      show_output = Cnfs.debug > 0
      Cnfs.silence_output(!show_output) { create_schema }
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
      # TODO Maybe this should be a setting to disable auto remove for debugging purposes
      FileUtils.rm_rf(dir)
    end

    # TODO: This is not DRY and requires knowledge from outside the class
    def self.dir; Cnfs.application.root.join(Cnfs.application.config.temp_dir).join('dump') end

    # Set up database tables and columns
    def self.create_schema
      ActiveRecord::Schema.define do
        create_table :applications, force: true do |t|
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
          t.string :path
        end
        ::Application.reset_column_information

        create_table :application_resources, force: true do |t|
          t.references :application
          t.references :resource
        end
        ApplicationResource.reset_column_information

        create_table :application_services, force: true do |t|
          t.references :application
          t.references :service
        end
        ApplicationService.reset_column_information

        create_table :assets, force: true do |t|
          t.string :name
          t.string :type
          t.string :path
          t.string :owner_type
          t.string :owner_id
        end
        Asset.reset_column_information

        create_table :contexts, force: true do |t|
          # t.references :target
          t.references :namespace
          t.references :deployment
          t.references :application
          t.string :name
          t.string :services
          t.string :resources
          t.string :tags
        end
        Context.reset_column_information

        create_table :context_services, force: true do |t|
          t.references :context
          t.references :service
        end
        ContextService.reset_column_information

        create_table :context_targets, force: true do |t|
          t.references :context
          t.references :target
        end
        ContextTarget.reset_column_information

        create_table :deployments, force: true do |t|
          t.references :application
          t.references :namespace
          t.references :key
          t.string :name
          t.string :config
          t.string :environment
          t.string :service_environments
        end
        Deployment.reset_column_information

        create_table :keys, force: true do |t|
          t.string :name
          t.string :value
        end
        Key.reset_column_information

        create_table :namespaces, force: true do |t|
          t.references :target
          t.string :name
          t.string :config
          t.string :environment
        end
        Namespace.reset_column_information

        create_table :providers, force: true do |t|
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
          # t.string :kubernetes
        end
        Provider.reset_column_information

        create_table :repositories, force: true do |t|
          t.string :name
          t.string :config
          t.string :type
        end
        Repository.reset_column_information

        create_table :runtimes, force: true do |t|
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
        end
        Runtime.reset_column_information

        create_table :resources, force: true do |t|
          t.string :name
          t.string :config
          t.string :environment
          t.string :resources
          t.string :type
          t.string :template
        end
        Resource.reset_column_information

        create_table :resource_tags, force: true do |t|
          t.references :resource
          t.references :tag
        end
        ResourceTag.reset_column_information

        create_table :services, force: true do |t|
          t.references :source_repo
          t.references :image_repo
          t.references :chart_repo
          t.string :name
          t.string :config
          t.string :environment
          t.string :type
          t.string :template
          t.string :path
        end
        Service.reset_column_information

        create_table :service_tags, force: true do |t|
          t.references :service
          t.references :tag
        end
        ServiceTag.reset_column_information

        create_table :tags, force: true do |t|
          t.string :name
          t.string :description
          t.string :config
          t.string :environment
        end
        Tag.reset_column_information

        create_table :targets, force: true do |t|
          t.references :runtime
          t.references :infra_runtime
          t.references :provider
          t.string :name
          t.string :config
          t.string :tf_config
          t.string :environment
          t.string :type
          t.string :namespaces
          t.string :dns_root_domain
        end
        Target.reset_column_information

        create_table :target_namespaces, force: true do |t|
          t.references :target
          t.references :namespace
        end
        TargetResource.reset_column_information

        create_table :target_resources, force: true do |t|
          t.references :target
          t.references :resource
        end
        TargetResource.reset_column_information

        create_table :target_services, force: true do |t|
          t.references :target
          t.references :service
        end
        TargetService.reset_column_information

        create_table :users, force: true do |t|
          t.string :name
          t.string :role
        end
        User.reset_column_information
      end
    end
  end
end
