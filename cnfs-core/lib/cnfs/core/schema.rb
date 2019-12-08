# frozen_string_literal: true

module Cnfs::Core
  class Schema
    def self.silence_output(silence = true)
      rs = $stdout
      $stdout = StringIO.new if silence
      yield
      $stdout = rs
    end

    # Set up database tables and columns
    def self.create_schema
			ActiveSupport::Inflector.inflections do |inflect|
				inflect.uncountable %w(dns kubernetes postgres redis)
			end
      # old_logger = ActiveRecord::Base.logger
      # ActiveRecord::Base.logger = nil
      silence_output do
				ActiveRecord::Schema.define do
					create_table :deployments, force: true do |t|
						t.references :application
						t.string :name
						t.string :environment
						t.string :platform_name
						t.string :base_path
					end
					Deployment.reset_column_information

					create_table :applications, force: true do |t|
						t.string :name
						t.string :config
						t.references :environment
						t.string :endpoints
						t.string :resources
						t.string :buckets
						t.string :cdns
					end
					Application.reset_column_information

					create_table :targets, force: true do |t|
						t.references :runtime
						t.references :provider
						t.string :config
						t.string :environment
						t.string :name
            t.boolean :sub_deploy

            t.string :dns
						t.string :globalaccelerator
						t.string :kubernetes
						t.string :postgres
						t.string :redis
						t.string :vpc
					end
					Target.reset_column_information

					create_table :deployment_targets, force: true do |t|
						t.references :deployment
						t.references :target
					end
					DeploymentTarget.reset_column_information

					create_table :layers, force: true do |t|
						t.string :config
						t.string :environment
						t.string :name
					end
					Layer.reset_column_information

					create_table :application_layers, force: true do |t|
						t.references :application
						t.references :layer
					end
					ApplicationLayer.reset_column_information

					create_table :target_layers, force: true do |t|
						t.references :target
						t.references :layer
					end
					ApplicationLayer.reset_column_information

					create_table :providers, force: true do |t|
						t.string :type
						t.string :config
						t.string :environment
						t.string :name
						t.string :credentials
            t.string :kubernetes
						t.string :storage
						t.string :mq
					end
					Provider.reset_column_information

					create_table :runtimes, force: true do |t|
						t.string :type
						t.string :config
						t.string :environment
						t.string :name
					end
					Runtime.reset_column_information

					create_table :environments, force: true do |t|
						t.string :name
						t.string :values
            # t.references :owner, polymorphic: true
					end
					Environment.reset_column_information

					# create_table :application_resources, force: true do |t|
					# 	t.references :application
					# 	t.references :resource
					# end
					# ApplicationResource.reset_column_information

					# Application::Service.joins(:layer).select(:name, 'application_layers.name as layer_name')'
					create_table :services, force: true do |t|
						t.references :layer
						t.string :type
						t.string :config
						t.string :environment
						t.string :name
						t.string :profiles
						t.boolean :ros
					end
					Service.reset_column_information
				end

				load_data
        # ActiveRecord::Base.logger = old_logger
      end
    end

    def self.load_data
      dir = Cnfs::Core.config_dir
      fixtures = Dir.chdir(dir) { Dir['**/*.yml'] }.map { |f| f.gsub('.yml', '') }
      ActiveRecord::FixtureSet.create_fixtures(dir, fixtures)
    end
  end
end
