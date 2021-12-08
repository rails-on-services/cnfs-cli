# frozen_string_literal: true

class Provisioner < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  # Resources assigned by the context
  attr_accessor :plans, :context_plans

  # Physical join table managed by the Provisioner
  has_many :provisioner_resources

  # This Operator manages target_type
  def target_type() = :plans

  # store :config, accessors: %i[version], coder: YAML

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
end
