# frozen_string_literal: true

# Begin with an OS ISO and create vmdk and ovf images
# See: https://www.packer.io/docs/builders/virtualbox/iso
class Builder::VirtualboxIso < Builder
  belongs_to :operating_system # , required: true

  store :config, accessors: %i[
    disk_size guest_additions_path headless http_directory
    output_directory shutdown_command ssh_password
    ssh_username ssh_wait_timeout vboxmanage vm_name
  ]

  # Used only by the next build's builder for its input
  # TODO: This should be an API of the builder base class
  def output_file
    "#{build.packer_name}/#{output_directory}/#{vm_name}.ovf"
  end

  def as_packer
    super.merge(operating_system.as_packer).merge(packer_add)
  end

  def packer_add
    {
      output_directory: output_directory || "builders/#{packer_name}/output",
      http_directory: http_directory || "builders/#{packer_name}/input",
      vm_name: vm_name || "#{build.full_name}-#{packer_name}"
    }
  end

  # NOTE: Called from BuildGenerator#generate
  def template(generator)
    operating_system&.template(generator, self)
  end
end
