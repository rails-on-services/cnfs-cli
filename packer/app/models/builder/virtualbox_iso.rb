# frozen_string_literal: true

class Builder::VirtualboxIso < Builder
  belongs_to :operating_system

  store :config, coder: YAML, accessors: %i[
    disk_size guest_additions_path headless
    output_directory shutdown_command ssh_password
    ssh_username ssh_wait_timeout vboxmanage
  ]

  def as_packer
    super.merge(operating_system.as_packer)
         .merge(vm_name: build.full_name, http_directory: "builders/#{build.packer_name}/input",
                output_directory: "builders/#{build.packer_name}/output")
  end
end
