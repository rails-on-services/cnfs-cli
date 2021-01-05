# frozen_string_literal: true

class Builder::VirtualboxOvf < Builder
  store :config, accessors: %i[
    guest_additions_mode headless
    output_directory shutdown_command source_path
    ssh_password ssh_username ssh_wait_timeout
  ]

  def as_packer
    super.merge(packer_add)
  end

  def packer_add
    {
      output_directory: output_directory || "builders/#{packer_name}/output",
      source_path: source_path || "../#{builder&.output_file}"
    }
  end

  # NOTE: Called from BuildGenerator#generate
  def template(generator)
    # operating_system&.template(generator, self)
  end

  # def as_packer
  #   super.merge(source_path: source_path)
  # end
end
