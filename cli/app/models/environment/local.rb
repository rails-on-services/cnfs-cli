# frozen_string_literal: true

class Environment::Local < Environment
  # belongs_to :instance, class_name: 'Resource'

  def resource_list
    %w[Resource::Aws::EC2 Resource::Aws::S3]
  end
end
