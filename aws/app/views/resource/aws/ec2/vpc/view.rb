# frozen_string_literal: true

class Resource::Aws::EC2::Vpc::View < ResourceView
  def edit
    model.azs = multi_select('Availabiity Zones:', model.available_azs) do |menu|
      # menu.default 1, 3
    end
  end
end
