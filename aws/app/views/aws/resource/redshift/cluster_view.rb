# frozen_string_literal: true

class Aws::Resource::Redshift::ClusterView < ResourceView
  attr_accessor :selected_family

  def edit
    @selected_family ||= prompt.enum_select('Instance family:', model.offers_by_family,
                                            per_page: per_page(model.offers_by_family))

    instance_types = model.instance_types(selected_family)
    model.node_type = enum_select('Node type:', instance_types, per_page: per_page(instance_types))
  end
end
