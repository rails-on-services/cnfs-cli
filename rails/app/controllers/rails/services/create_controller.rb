# frozen_string_literal: true

# Create a new CNFS Rails service in a project's repository
# Add the service configuration to the project
module Rails
  module Services
    module CreateController
      extend ActiveSupport::Concern
      include CommandHelper

      included do
        # NOTE: All CNFS derived services come from the CNFS plugin which knows what the dependent
        # gem is and whether the CNFS repo is available locally so whether it should be mapped or not
        # TODO: Add options that carry over to the rails plugin new command
        desc 'rails NAME', 'Create a new CNFS service based on the Ruby on Rails Framework'
        # option :database, desc: 'Preconfigure for selected database (options: postgresql)',
        #   aliases: '-D', type: :string, default: 'postgresql'
        # option :test_with, desc: 'Testing framework',
        #   aliases: '-t', type: :string, default: 'rspec'
        # option :gem,        desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
        #                     aliases: '-g', type: :string
        # option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
        #                     aliases: '-s', type: :string
        # TODO: removed the next option when refactored cnfs to cnfs_core gem; put it back when repository is active
        option :type,       desc: 'The service type to generate: application or plugin',
                            aliases: '-t', type: :string # , default: Cnfs.repository&.service_type
        cnfs_class_options :repository
        cnfs_options :force
        # TODO: Add before for type
        def rails(name)
          # TODO: Repository.from_path needs to return the default repository
          binding.pry
          repo = options.repository ? Repository.find_by(name: options.repository) : Repository.from_path
          raise Cnfs::Error, "Unknown repository #{options.repostiory}" unless repo
          
          # binding.pry
          # TODO: Need to fix this:
          # repo = Repository.where(name: options.repository).last
          repo = Repository.where(name: repo.name).last
          type = options.type || repo.service_type
          raise Cnfs::Error, "Unknown service type #{type}" unless %w[application plugin].include?(type)

          # Service.create(name: name, owner: repo)
          # Pathname.new(repo._source).sub_ext('').join("services/#{name}.yml")
          src = Pathname.new(repo._source).sub_ext('').join('images.yml')
          # s = Image.new(name: name, owner: repo, _source: src)
          s = Image.new(name: name, repository: repo, _source: src)
          binding.pry
          # TODO: Follow the repostiory_genrator pattern by having an invoke mathod on the base class
          generator = ServiceGenerator.new([repo, service], options)
          # generator.destination_root = Cnfs.repository.path
          generator.destination_root = repo.full_path.join("services/#{name}")

          # TODO: Dir check does not take into account full_service_name
          # service_path = "#{generator.destination_root}/services/#{name}"
          # binding.pry
          if Dir.exist?(generator.destination_root)
            raise Cnfs::Error, "service #{name} already exists" unless options.force

            FileUtils.rm_rf(generator.destination_root)
            # TODO: This also doesn't reverse the SDK
            # so it should run this with behvior revoke and then run again with invoke
          end

          generator.invoke_all
        end
      end
    end
  end
end
