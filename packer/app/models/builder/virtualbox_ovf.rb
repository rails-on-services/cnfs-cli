# frozen_string_literal: true

class Builder::VirtualboxOvf < Builder
  store :config, coder: YAML, accessors:
        %i[guest_additions_mode headless
           shutdown_command source_path
           ssh_password ssh_username ssh_wait_timeout]
  # output_directory shutdown_command source_path

  def source_path
    # TODO: select build.source.post_processors.where(type:
    super || "../#{build.source.packer_name}/builders/base-from-iso/output/fart-base-from-iso.ovf"
  end

  def as_packer
    super.merge(output_directory: "builders/#{build.packer_name}/output",
                source_path: source_path)
  end
end
