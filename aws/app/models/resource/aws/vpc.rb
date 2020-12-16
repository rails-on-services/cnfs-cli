# frozen_string_literal: true

class Resource::Aws::Vpc < Resource::Aws
  store :config, accessors: %i[azs], coder: YAML

  def configure(region:)
    self.region = region
    # TODO: Only preselect based on the values in config[:azs]
    self.azs = prompt.multi_select('Availabiity Zones:', available_azs) do |menu|
      menu.default 1, 3
    end
  end

  def available_azs
    ec2_client(region: region).describe_availability_zones[0].map { |z| z.zone_name }
  end
end
