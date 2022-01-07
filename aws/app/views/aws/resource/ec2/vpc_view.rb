# frozen_string_literal: true

class Aws::Resource::EC2::VpcView < ResourceView
  def edit
    model.azs = multi_select('Availabiity Zones:', model.available_azs) do |menu|
      # menu.default 1, 3
    end
  end
end
