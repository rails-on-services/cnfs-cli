
module Rails
  module RepositoriesController
    extend ActiveSupport::Concern

    included do
      add_cnfs_method_option(:create, 'cnfs_rails', desc: 'create a CNFS project', type: 'boolean')
      add_cnfs_action(:around_create, :create_cnfs_rails)

      # binding.pry
      desc 'rails NAME', 'Create a CNFS compatible repository for services based on the Ruby on Rails Framework'
      option :database,  desc: 'Preconfigure for selected database (options: postgresql)',
        aliases: '-D', type: :string, default: 'postgresql'
      option :test_with, desc: 'Testing framework',
        aliases: '-t', type: :string, default: 'rspec'
      option :namespace, desc: 'How services will be named: project, repository, service',
        type: :string, default: 'service'
      # TODO: Add options that carry over to the rails plugin new command
      def rails(name)
        # TODO: fix this issue with url being blank
        repo = ::Repository::Rails.create(name: name, url: 'h')
        generator = Rails::RepositoryGenerator.new([Cnfs.config.name, repo], options.merge(type: 'plugin')) # , source_repository: 'cnfs'))
        invoke(generator, repo)
      end
      register ::Repositories::CreateController, 'x_create', 'x_create TYPE NAME [options]', 'Create a new CNFS compatible services'
    end

    private
    def create_cnfs_rails
      Cnfs.logger.warn("before create from rails with #{args}")
      yield unless options.cnfs_rails
      Cnfs.logger.warn("after create from rails with #{args}")
    end
  end
end
