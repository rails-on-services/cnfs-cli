# frozen_string_literal: true

class Provisioner < ApplicationRecord
  include Concerns::Asset
  include Concerns::PlatformRunner

  has_many :blueprint_resources

  attr_accessor :resources, :context_resources

  store :config, accessors: %i[version], coder: YAML

  # This may be about TF modules rather than binaries like tf, kubectl, etc
  # TODO: Figure out how to manage these
  # def dependencies
  #   super.map(&:with_indifferent_access)
  # end

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
      # TODO: If this is for TF modules then maybe keep it, otherwise it goes to Platform
      t.string :dependencies
      # TODO: If providers is necessary than convert it into belongs_to_names
      t.string :providers
    end
  end
end
