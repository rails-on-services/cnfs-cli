# frozen_string_literal: true

class Aws::Resource::EC2::InstanceView < ResourceView
  def edit
    model.family = view_select(:instance_family, model.offers_by_family, model.family)
    instance_types = model.instance_types(model.family)
    model.size = view_select(:instance_type, instance_types, model.size)

    model.name ||= ask('Instance name:', value: random_string(blueprint.name))
    model.key_name = ask('Key pair:', value: model.key_name || '')
    os = enum_select('OS', os_values.keys)
    model.ami = os_images(os).sort_by{ |image| image.creation_date }.reverse.first.image_id
    model.instance_count = ask('Instance count:', value: model.instance_count.to_s, convert: :integer)
  end

  def os_images(os)
    model.describe_images(owners: [os_values[os][:owner]],
                          filters: [{ name: 'name', values: [os_values[os][:name]] }])
  end

  # TODO: these values should be in an external configuration file
  def os_values
    {
      debian: { owner: '136693071363', name: 'debian-10-amd64-*' },
      ubuntu: { owner: '099720109477', name: 'ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*' },
    }.with_indifferent_access
  end
end
