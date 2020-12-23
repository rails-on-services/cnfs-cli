# frozen_string_literal: true

class Resource::Aws::EC2::View < BaseView
  attr_accessor :model, :selected_family

  def render(model)
    @model = model
    blueprint = model.blueprint
    provider = blueprint.provider
    model.provider = provider

    @selected_family = select('Instance family:', per_page: TTY::Screen.rows - 3, filter: true, show_help: :always) do |menu|
      menu.choices offers_by_family
      menu.default ((offers_by_family.index(model.family) || 0) + 1) if model.family
      menu.help "(Wiggle thy finger up/down and left/right to see more)"
    end

    size = select('Instance type:', per_page: TTY::Screen.rows - 3, filter: true, show_help: :always) do |menu|
      menu.default ((instance_types.index(model.size) || 0) + 1) if model.size
      menu.choices instance_types
      menu.help "(Wiggle thy finger up/down and left/right to see more)"
    end

    model.family = selected_family
    model.size = size
    model.name ||= ask('Instance name:', value: "#{blueprint.name}_#{random_string}")
    model.key_name = ask('Key pair:', value: model.key_name)
    # model.eip = yes?('Attach an elastic IP?')
    os = enum_select('OS', %w[debian ubuntu])
    model.ami = os_images(os).sort_by{| s| s.creation_date }.reverse.first.image_id
    model.instance_count = ask('Instance count:', value: model.instance_count, convert: :integer)
  end

  def os_images(os)
    client.describe_images(owners: [os_owners[os.to_sym]], filters: [{name: "name", values: [os_names[os.to_sym]]}]).images
  end

  # TODO: these values should be in an external configuration file
  def os_owners
    { debian: '136693071363' }
  end

  def os_names
    { debian: 'debian-10-amd64-*' }
  end

  def instance_types
    @types ||= offers.select do |offer|
      offer.split('.').first.eql?(selected_family)
    end.map { |offer| offer.split('.').last }.sort
  end

  # def selected_family
  #   options = { per_page: offers_by_family.size, filter: true }
  #   options.merge!(value: model.instance_type.split('.').first) if model.instance_type
  #   # @selected_family ||= prompt.enum_select('Instance family:', offers_by_family, per_page: offers_by_family.size)
  #   @selected_family ||= select('Instance family:', offers_by_family, options) # per_page: offers_by_family.size, filter: true) do |menu|
  #   #   menu.default = model.instance_type.split('.').first if model.instance_type
  #   # end
  # end

  def offers_by_family
    @offers_by_family ||= offers.map { |offer| offer.split('.').first }.uniq.sort
  end

  def offers
    @offers ||= client.describe_instance_type_offerings[0].map { |offer| offer.instance_type }
  end

  def client; model.client end
end
