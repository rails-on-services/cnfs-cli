# frozen_string_literal: true

# This only applies to Component and Asset
module Concerns
  module NodeWriter
    extend ActiveSupport::Concern

    included do
      attr_writer :yaml_payload, :owner_class

      after_create :make_owner, if: proc { Node.source.eql?(:node) }

      # BEGIN: source asset

      after_create :write_yaml, if: proc { Node.source.eql?(:asset) }
      after_update :write_yaml, if: proc { Node.source.eql?(:asset) }
      after_destroy :destroy_yaml, if: proc { Node.source.eql?(:asset) }
    end

    # rubocop:disable Metrics/AbcSize
    def make_owner
      return if CnfsCli.support_names.include?(node_name)

      obj = parent.nil? ? @owner_class.create(yaml_payload) : owner_association.create(yaml_payload)
      return unless obj

      update(owner: obj)
      owner_log('Created owner')
    rescue ActiveModel::UnknownAttributeError, ActiveRecord::AssociationTypeMismatch, ActiveRecord::RecordInvalid => e
      # binding.pry
      Cnfs.logger.warn(e.message, yaml_payload)
      owner_log('Error creating owner')
    rescue NoMethodError => e
      Cnfs.logger.warn("#{e.message} in #{realpath}")
    end

    # rubocop:enable Metrics/AbcSize
    # Returns an A/R association, e.g. components, resources, etc
    # owner_association_name is implemented in Node::Component and Node::Asset
    def owner_association
      owner_ref(self).send(owner_association_name.to_sym)
    end

    def owner_log(title)
      Cnfs.logger.debug("#{title} from: #{pathname}\n#{yaml_payload}")
    end

    def yaml_payload
      @yaml_payload ||= { 'name' => node_name }.merge(yaml)
    end

    # BEGIN: source asset

    def write_yaml
      yaml_to_write = owner.as_json_encrypted.to_yaml
      Cnfs.logger.debug("Writing to #{realpath} with\n#{yaml_to_write}")
      File.open(realpath, 'w') { |f| f.write(yaml_to_write) }
    end
  end
end
