# frozen_string_literal: true

class Provisioner::Ansible < Provisioner
  store :config, coder: YAML, accessors: %i[
    ansible_env_vars extra_arguments host_alias playbook_file user
  ]

  def ansible_env_vars
    super || [
      'ANSIBLE_RETRY_FILES_ENABLED=false',
      "ANSIBLE_ROLES_PATH=#{Cnfs.project.packages_path.join('setup/roles')}"
    ]
  end

  def playbook_file
    super || Cnfs.project.packages_path.join('setup/cnfs-cli-instance.yml').to_s
  end
end
