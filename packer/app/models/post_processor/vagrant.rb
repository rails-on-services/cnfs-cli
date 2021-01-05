# frozen_string_literal: true

class PostProcessor::Vagrant < PostProcessor
  store :config, coder: YAML, accessors: %i[
    keep_input_artifact output
  ]

  # validates :output, presence: true

  def packer_add
    {
      output: output || output_path.join("#{packer_name}.box").to_s
    }
  end

  def output_path
    Pathname.new("post-processors/#{packer_name}/output")
  end

  def template(generator)
    # binding.pry
    generator.template('post_processor/vagrant/Vagrantfile.rb.erb', output_path.join('Vagrantfile'))
    # vgvp = path.join(vagrant_group_vars_path)
    # vgvp.mkpath unless vgvp.exist?
    # File.open(vgvp.join('db_instance.yml'), 'w') { |f| f.write(ansible_db_instance_vars.to_yaml) }
  end

  def vagrant_group_vars_path
    vagrant_inventory_path.join('group_vars')
  end

  def vagrant_inventory_path
    Pathname.new('.vagrant/provisioners/ansible/inventory')
  end

  def box
    'ros-generic-from-base.box'
  end

  def box_name
    'ros-generic-from-base'
  end

  def box_url
    'file:///Users/roberto/p3/projects/scratch2/test/builds/ros-generic-from-base/post-processors/ros-generic-from-base/output/ros-generic-from-base.box'
  end
end
