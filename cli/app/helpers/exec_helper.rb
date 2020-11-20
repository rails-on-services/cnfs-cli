# frozen_string_literal: true

module ExecHelper
  extend ActiveSupport::Concern

  included do
    attr_accessor :options, :arguments
  end

  def initialize(options:, arguments:)
    @options = options
    @arguments = arguments
  end

  def conditions
    hash = { name: service }
    if options.tags
      hash.merge!(tags: rt) if options.tags
    end
    hash.merge!(profile: options.profile) if options.profile
    hash
  end

  # def tags
  #   @tags ||= options.tags ? Hash[options.tags.each_slice(2).to_a] : {}
  # end

  # def user
  #   rt = tags.map{|k, v| "%#{k}: #{v}%"}
  #   # User.where('tags LIKE ?', '%status: cool%')
  #   User.where('tags LIKE ?', rt)
  # end

  def tags
    @tags ||= options.tags ? Hash[options.tags.each_slice(2).to_a] : {}
  end

  def rt; tags.map{|k, v| "%#{k}: #{v}%"}.join end

	def services; project.services end
	def runtime; project.runtime end
  def project; Cnfs.app end
end
