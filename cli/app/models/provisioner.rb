# frozen_string_literal: true

class Provisioner < ApplicationRecord
  include Concerns::Asset
  # include Concerns::BuilderRuntime

  # attr_accessor :blueprint

  # belongs_to :owner, polymorphic: true

  serialize :dependencies, Array

  # parse_scopes :config
  # parse_sources :cli

  def dependencies
    super.map(&:with_indifferent_access)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def download_dependencies
    return if dependencies.empty?

    require 'tty-file'
    require 'tty-spinner'

    path.mkpath unless path.exist?

    Dir.chdir(path) do
      # TODO: Move to terraform builder
      Pathname.new('.terraform/modules').rmtree if options.clean
      # rubocop:disable Naming/VariableNumber
      spinner = TTY::Spinner.new('[:spinner] Downloading dependencies ...', format: :pulse_2)
      # rubocop:enable Naming/VariableNumber
      dependencies.each do |dependency|
        file = dependency[:url].split(%r{/}).last
        if File.exist?(file) && !options.clean
          Cnfs.logger.info "Dependency #{dependency[:name]} exists locally. To overwrite run command with --clean flag."
          next
        end

        dep = dependency[:url].cnfs_sub
        spinner.run do |_spinner|
          if dependency[:type].eql?('repo')
            command.run(command_env, "git clone #{dep}", command_options)
          else
            TTY::File.download_file(dep)
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # TODO: What is this for?
  # def fetch_data_repo
  #   Cnfs.logger.info "Fetching data source v#{data.config.data_version}..."
  #   File.open('data.tar.gz', 'wb') do |fo|
  #     fo.write open("https://github.com/#{data.config.data_repo}/archive/#{data.config.data_version}.tar.gz",
  #                   'Authorization' => "token #{data.config.github_token}",
  #                   'Accept' => 'application/vnd.github.v4.raw').read
  #   end
  #   `tar xzf "data.tar.gz"`
  # end

  class << self
    def add_columns(t)
      t.string :dependencies
      t.string :providers
    end
  end
end
