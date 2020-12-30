# frozen_string_literal: true

class BuildGenerator < ApplicationGenerator
  argument :build

  # rubocop:disable Metrics/AbcSize
  def generate
    # TODO: somehow get the builder's values for which files to copy in
    directory('files/debian/buster64', "builders/#{build.packer_name}/input") # Cnfs.paths.data.join(build.full_name))
    build.post_processors.where(type: 'PostProcessor::Vagrant').each do |processor|
      path = Pathname.new("post-processors/#{processor.packer_name}/output")
      template('Vagrantfile.rb.erb', path.join('Vagrantfile'))
      vgvp = path.join(vagrant_group_vars_path)
      vgvp.mkpath unless vgvp.exist?
      File.open(vgvp.join('db_instance.yml'), 'w') { |f| f.write(ansible_db_instance_vars.to_yaml) }
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  # def provision(blueprint)
  #   @blueprint = blueprint
  #   # return if project_data_path.join('Vagrantfile').exist?
  #   File.open(project_data_path.join('Vagrantfile'), 'w') { |f| f.write(template_contents) }
  # end

  def vagrant_group_vars_path
    vagrant_inventory_path.join('group_vars')
  end

  def vagrant_inventory_path
    Pathname.new('.vagrant/provisioners/ansible/inventory')
  end

  # def ansible_strategy
  #   :remote
  #   # :local
  # end

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

  def internal_path
    Pathname.new(__dir__)
  end
end
