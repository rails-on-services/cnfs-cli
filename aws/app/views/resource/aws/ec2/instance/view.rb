# frozen_string_literal: true

class Resource::Aws::EC2::Instance::View < ResourceView
  attr_accessor :selected_family

  def edit
    @selected_family = select('Instance family:', per_page: per_page(model.offers_by_family), filter: true, show_help: :always) do |menu|
      menu.choices model.offers_by_family
      menu.default ((model.offers_by_family.index(model.family) || 0) + 1) if model.family
      menu.help 'Type to filter results'
    end

    instance_types = model.instance_types(selected_family)

    size = select('Instance type:', per_page: per_page(instance_types), filter: true, show_help: :always) do |menu|
      menu.default ((instance_types.index(model.size) || 0) + 1) if model.size
      menu.choices instance_types
      menu.help 'Type to filter results'
    end

    model.family = selected_family
    model.size = size
    model.name ||= ask('Instance name:', value: "#{blueprint.name}_#{random_string}")
    model.key_name = ask('Key pair:', value: model.key_name)
    # model.eip = yes?('Attach an elastic IP?')
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
