# frozen_string_literal: true

class Vagrant::Provisioner < Provisioner
  attr_accessor :blueprint

  store :config, accessors: %i[box box_url], coder: YAML
  # TODO: Vagrant and all that stuff needs to be installed on the laptop first
  # so ansible needs to be invoked to ensure it's all there

  # def box
  #   super || 'ros/generic'
  # end

  # def box_url
  #   super || 'ros/generic'
  #   super || 'https://perx-ros-boxes.s3-ap-southeast-1.amazonaws.com/vagrant/json/ros/generic.json'
  # end

  def provision(blueprint)
    @blueprint = blueprint
    # return if project_data_path.join('Vagrantfile').exist?
    File.open(project_data_path.join('Vagrantfile'), 'w') { |f| f.write(template_contents) }
    vagrant_group_vars_path.mkpath unless vagrant_group_vars_path.exist?
    File.open(vagrant_group_vars_path.join('db_instance.yml'), 'w') { |f| f.write(ansible_db_instance_vars.to_yaml) }
  end

  def vagrant_group_vars_path
    vagrant_inventory_path.join('group_vars')
  end

  def vagrant_inventory_path
    project_data_path.join('.vagrant/provisioners/ansible/inventory')
  end

  def ansible_strategy
    :remote
    # :local
  end

  def playbooks_to_provision
    packages_path.children.select(&:directory?).each_with_object([]) do |path, ary|
      playbook_path = path.join('cnfs-cli-instance.yml')
      ary.append(playbook_path) if playbook_path.exist?
    end
  end

  # TODO: This comes from the roles that the blueprint has defined which in turn is the resources selected by the user
  def ansible_roles
    roles = blueprint.resources.pluck(:type).map { |resource| resource.demodulize.underscore }
    roles.each_with_object({}) do |role, hash|
      hash[role] = [project_name]
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

  def project_name
    # The hostname set for the VM should only contain letters, numbers, hyphens or dots. It cannot start with a hyphen or dot
    # Strip any char that is not letter, number, hyphen or dot then strip any hypens and dots from the begining of the string
    @project_name ||= Cnfs.project.name.gsub(/[^0-9A-Za-z.-]+/, '').gsub(/^[-.]+/, '')
  end

  def template_contents
    ERB.new(File.read(template_file), trim_mode: '-').result(binding)
  end

  def template_file
    packages_path.join('setup', 'Vagrantfile.rb.erb')
  end

  def packages_path
    @packages_path ||= Cnfs.user_data_root.join('packages')
  end

  def project_data_path
    path = Cnfs.user_data_root.join('projects', Cnfs.project.name)
    path.mkpath unless path.exist?
    path
  end
end
