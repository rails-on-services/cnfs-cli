# frozen_string_literal: true

class ApplicationRecord < Cnfs::ApplicationRecord
  self.abstract_class = true

  store :config, coder: YAML

  def to_packer
    as_packer.deep_stringify_keys.sort.to_h
  end

  def as_packer
    raise Cnfs::Error, 'invalid' unless valid?

    attributes.with_indifferent_access
              .except(:build_id, :config, :id, :name, :order, :type)
              .merge(packer_type).merge(packer_config)
  end

  def packer_name
    name.tr('_', '-')
  end

  def packer_type
    { type: self.class.name.demodulize.underscore.tr('_', '-') }
  end

  def packer_config
    self.class.stored_attributes[:config].each_with_object({}) do |accessor, hash|
      hash[accessor] = send(accessor)
    end
  end

  class << self
    def permitted_scopes
      @permitted_scopes ||= %i[config build].to_set
    end
  end
end
