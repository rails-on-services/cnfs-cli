# frozen_string_literal: true

module Concerns
  module Operator
    extend ActiveSupport::Concern

    included do
      # extend ActiveModel::Callbacks

      include Concerns::Git

      attr_accessor :context

      # binding.pry
      define_model_callbacks :execute
    end

    # TODO:
    #   Implement as a before_execute callback
    #   Make this reusable by refactoring Pathname.rmtree and moving code back to Provisioner class
    def download(url, path, spinner = false)
      require 'tty-file'
      require 'tty-spinner'

      url = Pathname.new(url)
      path = Pathname.new(path)
      path.mkpath unless path.exist?

      Dir.chdir(path) do
        file = url.basename
        if File.exist?(file) # && !options.clean
          FileUtils.rm(file)
          Cnfs.logger.warn("#{file} exists")
          # Cnfs.logger.info "Dependency #{dependency[:name]} exists locally. To overwrite run command with --clean flag."
          # next
        end
        do_it(url, file, spinner)
      end
    end

    def do_it(url, file, spinner)
      if spinner
        spinner(file).run { |_spinner| more(url, file) }
      else
        more(url, file)
      end
    end

    def more(url, file)
      if git_url?(url.to_s)
        git_clone(url.to_s).run
      else
        TTY::File.download_file(url.to_s)
      end
    end

    # rubocop:disable Naming/VariableNumber
    def spinner(file)
      TTY::Spinner.new("[:spinner] Downloading #{file}...", format: :pulse_2)
    end
    # rubocop:enable Naming/VariableNumber

    # def initialize(**kwargs)
    #   assign_attributes(**kwargs)
    # end

    def platform
      @platform ||= Platform.new
    end

    # The classes including this concern are the ones that interface w/ the OS
    # serialize :dependencies, Array
    def dependencies
      # TODO: Implement
    end

    def queue
      @queue ||= CommandQueue.new
    end

    # method inherited from A/R base interferes with controller#destroy
    # undef_method :destroy
    def destroy; end

    def supported_commands
      raise NotImplementedError, 'To implement: returns an array of command names supported by this runtime'
    end

    # Check if the manifest is outdated and generate it if necessary
    def generate(force: false)
      manifest.purge! if context.options.generate
      return if manifest.valid? unless context.options.force

      manifest.purge!

      # TODO: why not set detination root? if a good reason then note it here
      # g.destination_root = manifest.write_path
      generator.invoke_all
      Cnfs.logger.warn("Invalid manifest: #{manifest.errors.full_messages}") unless manifest.valid?
    end

    delegate :manifest, to: :context

    def generator
      @generator ||= generator_class.new([context, self])
    end

    # Terraform::Provisioner becomes Terraform::ProvisionerGenerator
    def generator_class
      "#{self.class.name}Generator".constantize
    end

    def path(from: nil, to: :templates, absolute: false)
      context.path(from: from, to: to, absolute: absolute)
    end
  end
end
