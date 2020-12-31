# frozen_string_literal: true

class OperatingSystem < ApplicationRecord
  store :config, coder: YAML, accessors: %i[
    guest_os_type iso_checksum iso_checksum_type iso_url
  ]

  serialize :boot_command, Array

  parse_sources :cli, :project

  def as_packer
    super.except('type')
         .merge(guest_os_type: guest_os_type, iso_checksum: iso_checksum,
                iso_checksum_type: iso_checksum_type, iso_url: iso_url)
  end

  def as_save
    attributes.except('id', 'name')
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :boot_command
        t.string :name
        t.string :config
        t.string :type
      end
    end
  end
end
