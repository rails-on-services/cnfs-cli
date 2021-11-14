# frozen_string_literal: true

class Aws::Resource::EKS < Aws::Resource
  delegate :list_clusters, to: :client
end
