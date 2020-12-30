# frozen_string_literal: true

class Builder < ApplicationRecord
  store :config, accessors: %i[disk_size guest_additions_path guest_os_type headless
                               http_directory iso_checksum iso_checksum_type iso_url output_directory shutdown_command ssh_password
                               ssh_username ssh_wait_timeout type vboxmanage vm_name], coder: YAML
  serialize :boot_command, Array

  parse_sources :project

  def as_save
    attributes.except('id', 'name')
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :config
        t.string :boot_command
      end
    end
  end
end
