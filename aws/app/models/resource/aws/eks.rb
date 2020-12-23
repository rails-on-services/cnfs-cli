# frozen_string_literal: true

class Resource::Aws::EKS < Resource::Aws
  delegate :list_clusters, to: :client
end
