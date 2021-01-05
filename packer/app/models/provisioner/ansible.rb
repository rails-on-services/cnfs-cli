# frozen_string_literal: true

class Provisioner::Ansible < Provisioner
  store :config, accessors: %i[
    ansible_env_vars extra_arguments host_alias playbook_file user
  ]

  def packer_add
  # def set_defaults
    { ansible_env_vars: ansible_env_vars ||
      [
        'ANSIBLE_RETRY_FILES_ENABLED=false',
        "ANSIBLE_ROLES_PATH=#{Cnfs.project.packages_path.join('setup/roles')}"
      ],
      playbook_file: playbook_file || Cnfs.project.packages_path.join('setup/cnfs-cli-instance.yml').to_s
    }
  end

  def template(generator)
  end

  # def playbooks_to_provision
  #   packages_path.children.select(&:directory?).each_with_object([]) do |path, ary|
  #     playbook_path = path.join('cnfs-cli-instance.yml')
  #     ary.append(playbook_path) if playbook_path.exist?
  #   end
  # end

  # # TODO: This comes from the roles that the blueprint has defined which in turn is the resources selected by the user
  def ansible_roles
    roles = build.ansible_groups || []
    #   roles = blueprint.resources.pluck(:type).map { |resource| resource.demodulize.underscore }
    roles.each_with_object({}) do |role, hash|
      # hash[role] = [project_name]
      hash[role] = ['default']
    end
  end

  def ansible_db_instance_vars
    {
      users: {
        xpost: {
          password: 'rob'
        }
      }
    }.deep_stringify_keys!
  end
end
