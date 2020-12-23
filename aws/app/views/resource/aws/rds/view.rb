# frozen_string_literal: true

class Resource::Aws::RDS::View < BaseView

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
  end

  # TODO: Move prompt stuff to a controller
  def configure
    self.db_instance_class = prompt.enum_select('Instance class:', instance_types, per_page: instance_types.size)
    # resp = client.describe_reserved_db_instances({
    #   db_instance_class: "db.t2.micro", 
    #   duration: "1y", 
    #   multi_az: false, 
    #   offering_type: "No Upfront", 
    #   product_description: "mysql", 
    # })
  end

  def instance_types
    @types ||= offers.select { |offer| offer.start_with?(selected_family) }.sort
  end

  # def selected_family
  #   @selected_family ||= prompt.enum_select('Instance family:', offers_by_family, per_page: offers_by_family.size)
  # end

  def offers_by_family
    @offers_by_family ||= offers.map { |offer| offer.split('.').shift(2).join('.') }.uniq.sort
  end
  
  def offers
    @offers ||= client.describe_reserved_db_instances_offerings.
      reserved_db_instances_offerings.map { |offer| offer.db_instance_class }
  end
end
