# frozen_string_literal: true

class Aws::Resource::RDS::DBInstanceView < ResourceView
  attr_accessor :selected_family

  def edit
    @selected_family = select('Instance family:', per_page: per_page(model.offers_by_family), filter: true, show_help: :always) do |menu|
      menu.choices model.offers_by_family
      menu.default ((offers_by_family.index(model.family) || 0) + 1) if model.family
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
    model.name ||= ask('Instance name:', value: random_string(blueprint.name))
  end

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
end
